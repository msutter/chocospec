Function Push-Nupkg
{
    [CmdletBinding()]
    Param
    (
        # Specifies the nupkg files to update
        [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.nupkg } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [string]$Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ServerUrl,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]$ApiKey,

        [Parameter(Mandatory = $false, Position = 3)]
        [string]$TimeOut = 300,

        [ValidateScript( {Test-Path($_) } )]
        [Parameter(Mandatory = $false, Position = 4)]
        [string]$NugetCommand = 'C:\ProgramData\chocolatey\chocolateyinstall\NuGet.exe'
    )

    if ([System.IO.Path]::IsPathRooted($Path))
    {
        $AbsPath = $Path
    }
    else
    {
        $AbsPath = Join-Path -Path (Get-Location) -ChildPath $Path
    }

    $FileName = (Get-Item $AbsPath).Name
    & "$NugetCommand" push $AbsPath -Source $ServerUrl -ApiKey $ApiKey -Timeout $TimeOut

    Write-Verbose -Message "Package '${FileName}' Successfully uploaded to '${ServerUrl}'"
}
