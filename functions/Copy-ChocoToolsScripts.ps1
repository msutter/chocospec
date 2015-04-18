function Copy-ChocoToolsScripts
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
    #>
    [CmdletBinding()]
    Param
    (
        # Specifies the nuspec files to update
        [ValidateScript( { Test-Path($_) } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        $ToolsDirectory = './tools'
    )

    if ([System.IO.Path]::IsPathRooted($ToolsDirectory)) {
        $AbsToolsDirectory = $ToolsDirectory
    } else {
        $AbsToolsDirectory = Join-Path (Get-Location) -ChildPath $ToolsDirectory
    }

    Write-Verbose "AbsToolsDirectory: ${AbsToolsDirectory}"

    $ModulePath = Split-Path -Parent $PSScriptRoot
    Write-Verbose "ModulePath: ${ModulePath}"

    $FilesPath = "$ModulePath/files"
    Write-Verbose "FilesPath: ${FilesPath}"

    $null = Copy-Item -Path "${FilesPath}\chocolateyUninstall_ps1" `
        -Destination "${AbsToolsDirectory}\chocolateyUninstall.ps1"

    $null = Copy-Item -Path "${FilesPath}\chocolateyInstall_ps1" `
        -Destination "${AbsToolsDirectory}\chocolateyInstall.ps1"

    $null = Copy-Item -Path "${FilesPath}\chocolateyPkg_psd1" `
        -Destination "${AbsToolsDirectory}\chocolateyPkg.psd1"

}

