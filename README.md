# PSWebView
A template project for running Powershell commands using a WebView 'GUI' front-end. Uses WPF and part of the Microsoft.Web.WebView2 package which is available on NuGet.

## Dependencies
This project utilizes DLL files from the Microsoft.Web.WebView2 NuGet package.
Specifically:

- The project's `.\Lib\Microsoft.Web.WebView2.Core.dll` is from NuGet's `Microsoft.Web.WebView2\lib\net462\Microsoft.Web.WebView2.Core.dll`
- The project's `.\Lib\Microsoft.Web.WebView2.Wpf.dll` is from NuGet's `Microsoft.Web.WebView2\lib\net462\Microsoft.Web.WebView2.Wpf.dll`
- The project's `.\Lib\runtimes\win-x64\native\WebView2Loader.dll` is from NuGet's `Microsoft.Web.WebView2\runtimes\win-x64\native\WebView2Loader.dll`
- The project's `.\Lib\runtimes\win-x86\native\WebView2Loader.dll` is from NuGet's `Microsoft.Web.WebView2\runtimes\win-x86\native\WebView2Loader.dll`

This also requires the Microsoft Edge WebView2 Runtime (included in Windows 11 and Edge for Windows 10)

I'll possibly put in some kind of actual package management at some point but for now just grab it yourself, and make sure they're all from the same version.

## Dev Timeline
This is as much a learning project for me as well as a template for later works. As such, I'm stepping through features in a particular order. Additional stuff that comes up as I go will get put into Sidequests.

### Core Project
- [x] Launch Empty WPF window from Powershell
- [x] Load an external website
- [ ] Load local index.html page with virtual hostname
- [ ] Set up webpage -> PowerShell connectivity
- [ ] Set up Powershell -> webpage connectivity
- [ ] Request/Reply (promise calls)
- [ ] Command registry (locking down functionality)
- [ ] Push events
- [ ] Error handling
- [ ] Quality of Life Extras (mock fallback for webpage, headless mode for testing)

### Sidequests
- [ ] Rewrite WebHost initialisation and WebWindows code (the original code is heavily based on a colleague's own script, and I find it a little hard to read - at the very least I need to mark it up with some comments)
- [ ] Generally make wiring up commands as idiot-proof as possible

## Possible Uses
Currently, the base that I'm reading off of as I code this is used to run Active Directory powershell applets, it gives a nice step by step UI for making changes to user data and offboarding people (with a breadcrumb trail) and also populates with matching WFM system data in a read-only view. Changes made get automatically logged and copied to clipboard so they can be pasted as work notes. Very efficient.

After a recent deep dive into the newer Teams unified Events during some root cause analysis, I found myself wanting a friendly and clean way to view and manage calendar and event issues. So that may eventuate from this template eventually.
