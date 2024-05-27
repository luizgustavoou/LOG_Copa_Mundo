using System;
using System.Web.WebPages.Html;

public static class Util
{
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
}

