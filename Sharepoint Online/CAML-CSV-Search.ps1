const string csvPath = "C:\clients.csv";
static void Main()
{
  try
  {
    //Get site URL and credentials values from config
    Uri siteUri = new Uri(ConfigurationManager.AppSettings["SiteUrl"].ToString());
    var accountName = ConfigurationManager.AppSettings["AccountName"];
    char[] pwdChars = ConfigurationManager.AppSettings["AccountPwd"].ToCharArray();
 
    //Convert password to secure string
    System.Security.SecureString accountPwd = new System.Security.SecureString();
    for (int i = 0; i &lt; pwdChars.Length; i++)
    {
      accountPwd.AppendChar(pwdChars[i]);
    }
 
    //Connect to SharePoint Online
    using (var clientContext = new ClientContext(siteUri.ToString())
    {
      Credentials = new SharePointOnlineCredentials(accountName, accountPwd)
    })
    {
      if (clientContext != null)
      {
        //Map records from CSV file to C# list
        List records = GetRecordsFromCsv();
        //Get config-specified list
        List spList = clientContext.Web.Lists.GetByTitle(ConfigurationManager.AppSettings["ListName"]);
 
        foreach (CsvRecord record in records)
        {
          //Check for existing record based on title (assumes Title should be unique per record)
          CamlQuery query = new CamlQuery();
          query.ViewXml = String.Format("@" +
"" +
                        	"{0}" +
"", record.Title);
          var existingMappings = spList.GetItems(query);
          clientContext.Load(existingMappings);
          clientContext.ExecuteQuery();
 
          switch (existingMappings.Count)
          {
            case 0:
              //No records found, needs to be added
              AddNewListItem(record, spList, clientContext);
              break;
            default:
              //An existing record was found - continue with next item
              continue;
          }
        }
      }
    }
  }
  catch (Exception ex)
  {
    Trace.TraceError("Failed: " + ex.Message);
    Trace.TraceError("Stack Trace: " + ex.StackTrace);
  }
}