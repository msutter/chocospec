function Get-LastTag {
    <#
    .SYNOPSIS

    Returns the last tag of the current git branch

    .DESCRIPTION

    Returns the last tag of the current git branch

    #>
    [CmdletBinding()]
    Param
    (
        # Specifies the git repo path
        [ValidateScript( { Test-Path($_) } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [string]$Path,
        # Specifies the git binary command path
        [ValidateScript( { Test-Path($_) } )]
        [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
        [string]$GitCommand = 'C:\Program Files (x86)\Git\bin\git.exe'
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    $LastTag = & "${GitCommand}" -C ${AbsPath} describe --abbrev=0 --tags

    $LastTag
}