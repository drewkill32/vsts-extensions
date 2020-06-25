﻿namespace AzureDevOps_SharePoint_Link
{
    public class Resources
    {
        public const string ScriptWebPartXml = @"<webParts>
	  <webPart xmlns='http://schemas.microsoft.com/WebPart/v3'>
		<metaData>
		  <type name='Microsoft.SharePoint.WebPartPages.ScriptEditorWebPart, Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c' />
		  <importErrorMessage>Cannot import this Web Part.</importErrorMessage>
		</metaData>
		<data>
		  <properties>
			<property name='ExportMode' type='exportmode'>All</property>
			<property name='HelpUrl' type='string' />
			<property name='Hidden' type='bool'>False</property>
			<property name='Description' type='string'>Allows authors to insert HTML snippets or scripts.</property>
			<property name='Content' type='string'>{0}</property>
			<property name='CatalogIconImageUrl' type='string' />
			<property name='Title' type='string'>Script Editor</property>
			<property name='AllowHide' type='bool'>True</property>
			<property name='AllowMinimize' type='bool'>True</property>
			<property name='AllowZoneChange' type='bool'>True</property>
			<property name='TitleUrl' type='string' />
			<property name='ChromeType' type='chrometype'>None</property>
			<property name='AllowConnect' type='bool'>True</property>
			<property name='Width' type='unit' />
			<property name='Height' type='unit' />
			<property name='HelpMode' type='helpmode'>Navigate</property>
			<property name='AllowEdit' type='bool'>True</property>
			<property name='TitleIconImageUrl' type='string' />
			<property name='Direction' type='direction'>NotSet</property>
			<property name='AllowClose' type='bool'>True</property>
			<property name='ChromeState' type='chromestate'>Normal</property>
		  </properties>
		</data>
	  </webPart>
	</webParts>";
    }
}
