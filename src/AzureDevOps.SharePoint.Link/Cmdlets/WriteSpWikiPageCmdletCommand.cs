using AzureDevOps_SharePoint_Link;
using AzureDevOps_SharePoint_Link.Cmdlets;
using Microsoft.SharePoint.Client;
using Microsoft.SharePoint.Client.WebParts;
using System;
using System.IO;
using System.Linq;
using System.Management.Automation;

using IO = System.IO;

using Resources = AzureDevOps_SharePoint_Link.Resources;

namespace AzureDevOps.SharePoint.Link.Cmdlets
{
    [Cmdlet(VerbsCommunications.Write, "SpWikiPage", SupportsShouldProcess = true)]
    public class WriteSpWikiPageCmdletCommand : SpCmdletCommandBase
    {
        [Parameter(
            Mandatory = true,
            Position = 3,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string ListId { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 4,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string File { get; set; }

        [Parameter(
            Position = 5,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string Script { get; set; }

        protected override void ProcessRecord()
        {
            if (!Path.IsPathRooted(File))
            {
                File = Path.Combine(SessionState.Path.CurrentLocation.Path, File);
            }

            if (Script != null && !Path.IsPathRooted(Script))
            {
                Script = Path.Combine(SessionState.Path.CurrentLocation.Path, Script);
            }

            WriteObject($"Uploading {File} to {ListId}...");
            WriteVerbose($"ClientId:{ClientId} ClientSecret:{new String('*', ClientSecret.Length)}");
            WriteVerbose($"Url: {Url}");
            WriteVerbose($"File: {File} Script: {Script}");
            try
            {
                if (!IO.File.Exists(File))
                {
                    WriteError(new ErrorRecord(new FileNotFoundException($"The file {File} was not found.", File), "MissingFile", ErrorCategory.WriteError, new
                    {
                        Url,
                        ListId,
                        File,
                        Script
                    }));
                    return;
                }

                using (var cc = SpClientContext.GetClientContext(c =>
                {
                    c.Url = Url;
                    c.ClientId = ClientId;
                    c.ClientSecret = ClientSecret;
                }))
                {
                    var item = AddOrGetListItem(cc);

                    item["WikiField"] = IO.File.ReadAllText(File);

                    item.Update();
                    cc.ExecuteQuery();
                    WriteVerbose("Updated wiki content");

                    if (string.IsNullOrEmpty(Script))
                    {
                        WriteVerbose("No script to add.");
                    }
                    else
                    {
                        if (!IO.File.Exists(Script))
                        {
                            WriteError(new ErrorRecord(new FileNotFoundException($"The file {Script} was not found.", Script), "MissingFile", ErrorCategory.WriteError, new
                            {
                                Url,
                                ListId,
                                File,
                                Script
                            }));
                            return;
                        }

                        AddScript(cc, item);
                        WriteVerbose($"Added script");
                    }
                }
                WriteObject($"Uploaded {File} to {ListId}");
            }
            catch (Exception e)
            {
                WriteError(new ErrorRecord(e, "UploadFile", ErrorCategory.WriteError, new
                {
                    Url,
                    ListId,
                    File,
                    Script
                }));
            }
        }

        private void AddScript(ClientContext cc, ListItem item)
        {
            var wpm = item.File.GetLimitedWebPartManager(PersonalizationScope.Shared);

            // context.Load(wpm.WebParts, Function(wps) wps.Include(Function(wp) wp.WebPart.Properties, Function(wp) wp.Id))
            cc.Load(wpm.WebParts, wps => wps.Include(wp => wp.WebPart.Properties,
                wp => wp.Id,
                wp => wp.WebPart.ExportMode, wp => wp.ZoneId));
            cc.Load(item.File.ListItemAllFields);
            cc.ExecuteQuery();

            var content = IO.File.ReadAllText(Script);
            var escaped = new System.Xml.Linq.XText(content).ToString();

            var scriptWebPart = wpm.WebParts.FirstOrDefault(w =>
                w.WebPart.Properties["Title"].ToString().ToLowerInvariant().Contains("script"));
            if (scriptWebPart != null)
            {
                WriteVerbose("Web part found. replacing script content.");
                scriptWebPart.WebPart.Properties["Content"] = escaped;
                scriptWebPart.SaveWebPartChanges();
                cc.ExecuteQuery();
            }
            else
            {
                WriteVerbose("Web part does not exist. creating new web part");
                var newWp = wpm.ImportWebPart(String.Format(Resources.ScriptWebPartXml, escaped));
                var webPartToAdd = wpm.AddWebPart(newWp.WebPart, "Left", 0);
                cc.Load(webPartToAdd);
                cc.ExecuteQuery();
            }
        }

        private ListItem AddOrGetListItem(ClientContext cc)
        {
            var wikiPageName = Path.GetFileNameWithoutExtension(File) + ".aspx";

            var list = cc.Web.Lists.GetById(new Guid(ListId));
            cc.Load(cc.Web);
            cc.Load(list);
            // Load pages list and relative URL of the list
            cc.Load(list.RootFolder, f => f.ServerRelativeUrl);

            var query = new CamlQuery();
            query.ViewXml = "<View Scope=\"RecursiveAll\">\r\n    <Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='File'>" + wikiPageName + "</Value></Eq></Where></Query>\r\n</View>";
            var items = list.GetItems(query);
            cc.Load(items, icol => icol.Include(
                i => i.File.ListItemAllFields,
                i => i["WikiField"]));
            cc.ExecuteQuery();
            if (items.Any())
            {
                WriteVerbose($"Wiki Page {wikiPageName} found.");
                return items.First();
            }
            WriteVerbose($"Wiki Page {wikiPageName} does not exist. Creating {wikiPageName}");
            // Get the server relative URL of the Pages library
            var pageLibraryUrl = list.RootFolder.ServerRelativeUrl;
            var newWikiPageUrl = pageLibraryUrl + "/" + wikiPageName;

            // Specify template file Type = Wikipage
            var newPage = list.RootFolder.Files.AddTemplateFile(newWikiPageUrl, TemplateFileType.WikiPage);
            cc.Load(newPage);
            cc.ExecuteQuery();
            WriteVerbose($"Created {wikiPageName}");
            return newPage.ListItemAllFields;
        }
    }
}