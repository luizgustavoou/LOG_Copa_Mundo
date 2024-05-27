using System;
using System.Activities.Statements;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Helpers;

public class ErroExecucaoException : Exception
{
    public List<dynamic> Errors;

    public ErroExecucaoException(List<SqlError> errors)
    {
        Errors = new List<dynamic>();

        foreach (SqlError item in errors)
        {
            // 3609 = The transaction ended in the trigger. The batch has been aborted.
            if (item.Number == 3609) return;

            // o erro 50001 já vem no formato json, só precisa retornar
            if(item.Number == 50001)
            {
                dynamic erro = Json.Decode(item.Message);

                // adiciona o objeto na lista

                Errors.Add(erro);
            }else
            {
                throw new Exception(item.Message);
            }
        }
    }
}