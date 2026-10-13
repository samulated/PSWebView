<#
    AAA
#>

$script:Root = $PSScriptRoot

. (Join-Path $script:Root 'Lib\WebHost.ps1')

Initialize-WebHost

New-WebWindow "The Google" "https://www.google.com/" $script:Root
Start-WebApp

Write-Output $script:Root