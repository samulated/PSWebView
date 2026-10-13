

function Initialize-WebHost {
    Write-Output("Beginning WebHost init.")
    $lib = Join-Path $script:Root 'Lib'
    Write-Output("- Adding Assemblies")
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml, System.Windows.Forms
    Write-Output("- Adding AdminCli")
    if (-not ('AdminCli.Native' -as [type])) {
        Add-Type -Namespace AdminCli -Name Native -MemberDefinition '[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)] public static extern IntPtr LoadLibrary(string path);'
    }
    Write-Output("- Detecting Arch")
    $arch = if ([IntPtr]::Size -eq 8) {'win-x64'} else {'win-x86'}
    Write-Output("- Setting loader")
    $loader = Join-Path $lib "runtimes\$arch\native\WebView2Loader.dll"
    if (-not (Test-Path $loader)) {throw "Missing $loader"}
    Write-Output("- Setting native")
    $native = Split-Path -Parent $loader
    if (($env:PATH -split ';') -notcontains $native) { $env:PATH = "$native;$env:PATH" }
    Write-Output("- Loading library")
    $h = [AdminCli.Native]::LoadLibrary($loader)
    if ($h -eq [IntPtr]::Zero) { throw "Could not load $loader (Win32 error $([Runtime.InteropServices.Marshal]::GetLastWin32Error())). Unblock files in Lib\ abd try again."}
    Write-Output("- Adding WebView dlls")
    Add-Type -Path (Join-Path $lib 'Microsoft.Web.WebView2.Core.dll')
    Add-Type -Path (Join-Path $lib 'Microsoft.Web.WebView2.Wpf.dll')
    Write-Output("- Final check")
    try {
        $ver = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::GetAvailableBrowserVersionString()
        if ([string]::IsNullOrWhiteSpace($ver)) { throw 'no version' }
        $script:WebRuntimeVersion = $ver
    } catch {
        throw "The Microsoft Edge WebView2 Runtime is not installed on this PC. It ships with Windows 11 and with Edge on Windows 10; otherwise install the Evergreen runtime from http://developer.microsoft.com/microsoft-edge/webview2/ and run the tool again."
    }
    Write-Output("Initialized successfully.")
}

function New-Window {
    param([Parameter(Mandatory)][string]$Title, [int]$Width = 800, [int]$Height = 600)

    $win = New-Object System.Windows.Window
    $win.Title = $Title
    $win.Width = $Width; $win.Height = $Height
    $win.WindowStartupLocation = 'CenterScreen'
    $win.ShowDialog()

    return $win
}

function New-WebWindow {
    param([Parameter(Mandatory)][string]$Title, [Parameter(Mandatory)][string]$Page, [Parameter(Mandatory)][string]$WebRoot, [int]$Width = 800, [int]$Height = 600)
    Write-Output("Starting up webpage with following parameters: $Title, $Page, $WebRoot, $Width, $Height")

    $win = New-Object System.Windows.Window
    $win.Title = $Title
    $win.Width = $Width; $win.Height = $Height
    $win.WindowStartupLocation = 'CenterScreen'

    <# $WebRoot to be used for setting .ico of window #>

    $wv = New-Object Microsoft.Web.WebView2.Wpf.WebView2
    $props = New-Object Microsoft.Web.WebView2.Wpf.CoreWebView2CreationProperties
    $data = Join-Path $env:LOCALAPPDATA 'AdminCLI\WebView2'
    if (-not (Test-Path $data)) { New-Item -ItemType Directory -Path $data -Force | Out-Null }
    $props.UserDataFolder = $data
    $props.AdditionalBrowserArguments = '--disable-features=msSMartScreenProtection'
    $wv.CreationProperties = $props
    $wv.DefaultBackgroundColor = [System.Drawing.Color]::FromArgb(255,15,18,24)
    $win.Content = $wv
    $script:WebView = $wv
    $script:WebWindow = $win
    $script:WebPage = $Page
    $script:WebRoot = $WebRoot

    $wv.add_CoreWebView2InitializationCompleted([EventHandler[Microsoft.Web.WebView2.Core.CoreWebView2InitializationCompletedEventArgs]]{
        param($s, $e)
        try {
            if (-not $e.IsSuccess) { throw $e.InitializationException }
            Write-Output("Attempting to load page..")
            $core = $script:WebView.CoreWebView2
            $core.Navigate("$script:WebPage")
        } catch {
            $script:WebInitError = $_.Exception.Message
            $script.WebWindow.Close()
        }
    })
    $win.add_Loaded({
        param($s, $e)
        try {
            $script:WebView.EnsureCoreWebView2Async($null) | Out-Null
        } catch {
            $script:WebInitError = $_.Exception.Message;
            $script:WebWindow.Close() 
        }
    })
    $win.add_Closing({
        param($s, $e)
        <#
            This is where you can call back a WebOnQuit script block
            via the $script:WebOnQuit var
        #>
    })
    return $win
}

function Start-WebApp {
    if (-not $script:WebWindow) { return }
    $script:WebWindow.ShowDialog() | Out-Null
    if ($script:WebInitError) { throw "The window could not start: $($script:WebInitError)" }
}