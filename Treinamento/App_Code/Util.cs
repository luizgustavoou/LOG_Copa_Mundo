using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.WebPages.Html;
using static Util;

public static class Util
{

    public  enum TypeFormat
    {
        BRAZIL_DATE = 23,
        AMERICAN_DATE = 103,
        TIME_DEFAULT = 108
    }

    private static Dictionary<TypeFormat, string> styles = new Dictionary<TypeFormat, string>()
    {
        { TypeFormat.BRAZIL_DATE, "dd/MM/yyyy" },
        { TypeFormat.AMERICAN_DATE, "yy/MM/dd" },
        { TypeFormat.TIME_DEFAULT, "HH:mm:ss" }
    };



public static string ChecaNulo(string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return null;
        }

        return str.Trim();
    }

    public static void ExceptionHandler(Action action, ModelStateDictionary model)
    {
        try
        {
            action();
        }
        catch (ErroExecucaoException ex)
        {
            model.AddError("alert-warning", "Por favor, verifique o formulário");

            foreach (dynamic item in ex.Errors)
            {
                model.AddError(item.NomeInput, item.Mensagem);
                
            }
        }
        catch (Exception ex)
        {
            model.AddError("alert-danger", ex.Message);

        }
    }

    public static string FormatarData(string data, TypeFormat style)
    {

        return DateTime.Parse(data).ToString(styles[style]);

        
    }
}

