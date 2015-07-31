function Get-CommitHash {
    <#
    .SYNOPSIS

    Returns the commit hash

    .DESCRIPTION

    Returns the commit hash

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
        [string]$GitCommand = 'C:\Program Files (x86)\Git\bin\git.exe',
        # Specifies the number of digits
        [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true )]
        [switch]$Short
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    if ($Short) {
        $CommitHash = & "${GitCommand}" -C ${AbsPath} rev-parse --short HEAD
    } else {
        $CommitHash = & "${GitCommand}" -C ${AbsPath} rev-parse HEAD
    }

    $CommitHash
}