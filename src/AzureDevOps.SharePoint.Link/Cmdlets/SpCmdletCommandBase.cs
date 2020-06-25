using System;
using System.Management.Automation;
using Microsoft.SharePoint.Client;
using File = System.IO.File;

namespace AzureDevOps_SharePoint_Link.Cmdlets
{
    public abstract class SpCmdletCommandBase:PSCmdlet
    {


        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string ClientId { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 1,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string ClientSecret { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 2,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string Url { get; set; }


        protected void UploadFile(string file, string documentFolder)
        {
            if (!System.IO.Path.IsPathRooted(file))
            {

                file = System.IO.Path.Combine(SessionState.Path.CurrentLocation.Path, file);
            }
            WriteObject($"Uploading {file} to {documentFolder}...");
            WriteVerbose($"ClientId:{ClientId} ClientSecret:{new String('*', ClientSecret.Length)}");
            WriteVerbose($"Url: {Url}");
            WriteVerbose($"DocumentFolder: {documentFolder} File: {file}");
            if (ShouldProcess("Uploading file"))
            {
                try
                {
                    using (var cc = SpClientContext.GetClientContext(c =>
                    {
                        c.Url = Url;
                        c.ClientId = ClientId;
                        c.ClientSecret = ClientSecret;
                    }))
                    {
                        var folder = cc.Web.GetFolderByServerRelativeUrl(documentFolder);
                        cc.Load(cc.Web);
                        cc.Load(folder, f => f.Files);
                        var newFile = new FileCreationInformation
                        {
                            ContentStream = System.IO.File.OpenRead(file),
                            Url = System.IO.Path.GetFileName(file),
                            Overwrite = true
                        };

                        var uploadFile = folder.Files.Add(newFile);
                        cc.Load(uploadFile);
                        cc.ExecuteQuery();
                    }
                    WriteObject($"Uploaded {file} to {documentFolder}");
                }
                catch (Exception e)
                {

                    WriteError(new ErrorRecord(e, "UploadFile", ErrorCategory.WriteError, new
                    {
                        Url,
                        file,
                        DocumentFolder = documentFolder
                    }));
                }
            }
        }

    }
}
