# vsts-extensions


## Regiser a new app with SharePoint

SharePoint requires an app is registered with SharePoint using a ClientId and Secret. To create a new SharePoint App visit the endpoint */_layouts/15/AppRegNew.aspx* on your SharePoint site.

Example:
```
https://contoso.sharepoint.com/_layouts/15/AppRegNew.aspx
```

## Grant app permissions
Once you have created your app you have to grant permissions for the app on SharePoint. To generate the permissions visit the */_layouts/15/AppInv.aspx* on your SharePoint site.
Enter the same settings you entered when creating the app. For the Permissions XML follow this [CheatSheet](https://medium.com/ng-sp/sharepoint-add-in-permission-xml-cheat-sheet-64b87d8d7600) for suggestions.

Example:
```xml
<AppPermissionRequests AllowAppOnlyPolicy="true">  
   <AppPermissionRequest Scope="http://sharepoint/content/sitecollection" 
    Right="FullControl" />
</AppPermissionRequests>
```

## View a list of registered apps
To view a list of registered app on SharePoint go to the url https://{SHAREPOINT_SITE}/_layouts/15/appprincipals.aspx

Example:
```
https://contoso.sharepoint.com/_layouts/15/appprincipals.aspx
```
