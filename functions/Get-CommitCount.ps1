function Get-CommitCount {
    <#
    .SYNOPSIS

    Returns the commit count

    .DESCRIPTION

    Returns the commit count

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
        [int]$Digits = 5
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    $CommitCount = & "${GitCommand}" -C ${AbsPath} rev-list HEAD --count
    $FormattedBuild = "{0:D${Digits}}" -f [int]$CommitCount

    $FormattedBuild
}