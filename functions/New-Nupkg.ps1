Function New-Nupkg
{
    [CmdletBinding()]
    Param
    (
        # Specifies the nupkg files to update
        [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.nuspec } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [string]$NuspecPath,

        # Specifies the nupkg files to update
        [ValidateScript( { Test-Path($_) -PathType Container } )]
        [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
        [string]$OutputDirectory = (Get-Location),

        [ValidateScript( { Test-Path($_) -PathType Container } )]
        [Parameter(Mandatory = $false)]
        [string]$BasePath = './',

        [ValidateScript( {Test-Path($_) } )]
        [Parameter(Mandatory = $false)]
        [string]$NugetCommand = 'C:\ProgramData\chocolatey\chocolateyinstall\NuGet.exe'

    )
    try {
        if ([System.IO.Path]::IsPathRooted($NuspecPath))
        {
            $AbsNuspecPath = $NuspecPath
        }
        else
        {
            $AbsNuspecPath = Join-Path -Path (Get-Location) -ChildPath $NuspecPath
        }

        & "${NugetCommand}" pack "${AbsNuspecPath}" -BasePath "${BasePath}" -OutputDirectory "${OutputDirectory}" -NoPackageAnalysis

    } catch {
      Write-Error "$($_.Exception.Message)"
      throw
    }

}
