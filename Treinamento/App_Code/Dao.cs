using System.Data.SqlClient;
using System.Collections.Generic;
using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Reflection;
using System.Linq;

public class Dao
{
    private class Autorizacao
    {
        public string NomeProcedure { get; set; }
    }

    private readonly string stringConexao = "Server=winserver2022;Database=dbTreinamento;Trusted_Connection=True;";




    public void ExecutarProcedure(string procedure, Dictionary<string, object> parametros)
    {

        List<SqlError> errors = null;

        SqlConnection conn = new SqlConnection(stringConexao);

        conn.Open();

        SqlCommand cmmd = NovoCmd(procedure, conn);


        AdicionarParametros(cmmd, parametros);

        // seta a configuração para disparar um evento, quando acontecer um erro de baixa relevancia na procedure
        conn.FireInfoMessageEventOnUserErrors = true;

        conn.InfoMessage += new SqlInfoMessageEventHandler((object sender, SqlInfoMessageEventArgs e) =>
        {
            // se a lista nao estiver instanciada
            if(errors == null)
            {
                // instancia uma nova lista
                errors = new List<SqlError>();
            }

            foreach (SqlError item in e.Errors)
            {
                // adiciona os errors na lista
                errors.Add(item);
            }
        });

        cmmd.ExecuteNonQuery();

        if(errors != null)
        {
            throw new ErroExecucaoException(errors);
        }

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

    public List<T> ExecutarAcaoList<T>(string acao, Dictionary<string, object> parametros)
    {
        string procedure = GetNomeProcedure(acao);

        return ExecutarProcedureList<T>(procedure, parametros);
    }

    public void ExecutarAcao(string acao, Dictionary<string, object> parametros)
    {
        string procedure = GetNomeProcedure(acao);

        ExecutarProcedure(procedure, parametros);
    }

    private string GetNomeProcedure(string acao)
    {
        Identificacao identificacao = new Identificacao();

        Dictionary<string, object> parametros = new Dictionary<string, object>();

        parametros.Add("@TipoConsulta", "C_Acao");
        parametros.Add("@IdOperador", identificacao.IdOperador);
        parametros.Add("@CodigoSistema", identificacao.Sistema);
        parametros.Add("@CodigoModulo", identificacao.Modulo);
        parametros.Add("@CodigoPagina", identificacao.Pagina);
        parametros.Add("@CodigoAcao", acao);

        List<Autorizacao> autorizacoes = ExecutarProcedureList<Autorizacao>("stp_LGU_MontaMenu", parametros);

        if (autorizacoes == null) // != null
        {
            throw new InvalidOperationException("Operador não autorizado para executar essa ação");
        }


        return autorizacoes.FirstOrDefault().NomeProcedure;
    }

    public List<T> ExecutarProcedureList<T>(string procedure, Dictionary<string, object> parametros)
    {
        List<SqlError> errors = null;
        List<T> list = null;


        SqlConnection conn = new SqlConnection(stringConexao);

        conn.Open();

        SqlCommand cmmd = NovoCmd(procedure, conn);


        AdicionarParametros(cmmd, parametros);

        // seta a configuração para disparar um evento, quando acontecer um erro de baixa relevancia na procedure
        conn.FireInfoMessageEventOnUserErrors = true;

        conn.InfoMessage += new SqlInfoMessageEventHandler((object sender, SqlInfoMessageEventArgs e) =>
        {
            // se a lista nao estiver instanciada
            if (errors == null)
            {
                // instancia uma nova lista
                errors = new List<SqlError>();
            }

            foreach (SqlError item in e.Errors)
            {
                // adiciona os errors na lista
                errors.Add(item);
            }
        });

        SqlDataReader dr = cmmd.ExecuteReader();

        if (errors != null)
        {
            throw new ErroExecucaoException(errors);
        }

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