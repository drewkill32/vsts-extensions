using Microsoft.SharePoint.Client;
using OfficeDevPnP.Core;
using System;

namespace AzureDevOps_SharePoint_Link
{
    public class SpClientContext
    {
        public static ClientContext GetClientContext(Action<SpSettings> config)
        {
            var settings = new SpSettings();
            config(settings);
            return new AuthenticationManager()
                .GetAppOnlyAuthenticatedContext(settings.Url,
                    settings.ClientId,
                    settings.ClientSecret);
        }
    }
}
