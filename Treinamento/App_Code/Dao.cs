using System.Data.SqlClient;
using System.Collections.Generic;
using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Reflection;

public class Dao
{
    


    private readonly string stringConexao = "Server=winserver2022;Database=dbTreinamento;Trusted_Connection=True;";


    public void ExecutarProcedure(string procedure, Dictionary<string, object> parametros)
    {

        SqlConnection conn = new SqlConnection(stringConexao);

        conn.Open();

        SqlCommand cmmd = NovoCmd(procedure, conn);


        AdicionarParametros(cmmd, parametros);

        cmmd.ExecuteNonQuery();

        cmmd.Dispose();

        conn.Close();
        conn.Dispose();
    }

    private SqlCommand NovoCmd(string procedure, SqlConnection conn)
    {
        return  new SqlCommand(procedure, conn)
        {
            CommandType = System.Data.CommandType.StoredProcedure,
            CommandTimeout = 60
        };
    }

    public List<T> ExecutarProcedureList<T>(string procedure, Dictionary<string, object> parametros)
    {
        List<T> list = null;


        SqlConnection conn = new SqlConnection(stringConexao);

        conn.Open();

        SqlCommand cmmd = NovoCmd(procedure, conn);


        AdicionarParametros(cmmd, parametros);

        SqlDataReader dr = cmmd.ExecuteReader();

        list = CriaLista<T>(dr);

        dr.Close();
        dr.Dispose();

        cmmd.Dispose();

        conn.Close();
        conn.Dispose();


        return list;
    }

    private void AdicionarParametros(SqlCommand cmmd, Dictionary<string, object> parametros)
    {
        if (parametros != null)
        {
            foreach (var item in parametros)
            {
                cmmd.Parameters.AddWithValue(item.Key, item.Value);
            }
        }
    }

    private List<T> CriaLista<T>(SqlDataReader dr)
    {
        List<T> list = null;

        if(dr.HasRows)
        {
            list = new List<T>();

            while(dr.Read())
            {
                var item = Activator.CreateInstance<T>();

                foreach (var property in typeof(T).GetProperties())
                {
                    string nomecoluna;

                    if(property.GetCustomAttribute<ColumnAttribute>() != null)
                    {
                        nomecoluna = property.GetCustomAttribute<ColumnAttribute>().Name;
                    }else
                    {
                        nomecoluna = property.Name;
                    }

                    int i = GetColumnOrdinal(dr, nomecoluna);

                    if (i < 0) continue;

                    if (dr[nomecoluna] == DBNull.Value) continue;

                    if(property.PropertyType.IsEnum)
                    {
                        property.SetValue(item, Enum.Parse(property.PropertyType, dr[nomecoluna].ToString()));
                    }else
                    {
                        Type convertTo = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                        property.SetValue(item, Convert.ChangeType(dr[nomecoluna], convertTo));
                    }
                }

                list.Add(item);

            }
        }

        return list;
    }

    private int GetColumnOrdinal(SqlDataReader dr, string columnName)
    {
        int ordinal = -1;

        for(int i=  0; i < dr.FieldCount; i++)
        {
            if(string.Equals(dr.GetName(i), columnName, StringComparison.OrdinalIgnoreCase))
            {
                ordinal = i;
                break;
            }

        }

        return ordinal;

    }
}