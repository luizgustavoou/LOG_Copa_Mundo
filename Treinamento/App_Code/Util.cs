using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Web.WebPages.Html;
using static Util;

public static class Util
{

    public  enum TypeFormat
    {
        BRAZIL_DATE = 23,
        BRAZIL_DATETIME = 24,
        AMERICAN_DATE = 103,
        AMERICAN_DATETIME = 104,
        TIME_DEFAULT = 108
    }

    private static Dictionary<TypeFormat, string> styles = new Dictionary<TypeFormat, string>()
    {
        { TypeFormat.BRAZIL_DATETIME, "dd-MM-yyyy HH:mm:ss" },
        { TypeFormat.BRAZIL_DATE, "dd-MM-yyyy" },
        { TypeFormat.AMERICAN_DATETIME, "yyyy-MM-dd HH:mm:ss" },
        { TypeFormat.AMERICAN_DATE, "yyyy-MM-dd" },
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
        string saida = DateTime.Parse(data).ToString(styles[style]);

        return saida;

        
    }

    public static string GenerateUniqueFileName(string originalFileName)
    {
        // Obtém a extensão do arquivo original
        string fileExtension = Path.GetExtension(originalFileName);

        // Gera um nome de arquivo único usando Guid
        string uniqueFileName = Guid.NewGuid().ToString();

        // Concatena o nome único com a extensão do arquivo original
        string uniqueFileNameWithExtension = uniqueFileName + fileExtension;

        return uniqueFileNameWithExtension;
    }
}

