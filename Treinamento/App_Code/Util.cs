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
}