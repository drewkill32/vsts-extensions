using Microsoft.SharePoint.Client;
using System;
using IO =System.IO;
using System.Management.Automation;

namespace AzureDevOps_SharePoint_Link.Cmdlets
{
    [Cmdlet(VerbsCommunications.Write, "SpFile",SupportsShouldProcess = true)]

    public class WriteSpFileCmdletCommand : SpCmdletCommandBase
    {

        [Parameter(
            Mandatory = true,
            Position = 3,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string DocumentFolder { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 4,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string File { get; set; }


        // This method will be called for each input received from the pipeline to this cmdlet; if no input is received, this method is not called
        protected override void ProcessRecord()
        {
           UploadFile(File,DocumentFolder);
        }

    }
}
