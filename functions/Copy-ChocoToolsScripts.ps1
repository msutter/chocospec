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
        $ToolsDirectory = './tools',

        [Parameter(Mandatory = $false)]
        [string[]]$ScriptKeys = @('chocolateyInstall','chocolateyUninstall')
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

    if ($scriptKeys.Contains('chocolateyInstall')) {
        # $null = Copy-Item -Path "${FilesPath}\chocoSpecInstall.ps1" `
        #     -Destination "${AbsToolsDirectory}\chocolateyInstall.ps1"
        $null = Robocopy "${FilesPath}" "${AbsToolsDirectory} chocolateyInstall.ps1"
    }

    if ($scriptKeys.Contains('chocolateyUninstall')) {
        # $null = Copy-Item -Path "${FilesPath}\chocoSpecUninstall.ps1" `
        #     -Destination "${AbsToolsDirectory}\chocolateyUninstall.ps1"
        $null = Robocopy "${FilesPath}" "${AbsToolsDirectory} chocolateyUninstall.ps1"
    }

}

