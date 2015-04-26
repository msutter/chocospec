function Invoke-ChocoBuildPrep {
<#
.SYNOPSIS

.DESCRIPTION
Script commands to "prepare" the program (e.g. to uncompress it) so that it will be ready for building.
Typically this is just "%autosetup"; a common variation is "%autosetup -n NAME" if the source file unpacks into NAME.
See the %prep section below for more.

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $false)]
    [switch] $T,

    [Parameter(Mandatory = $false)]
    [string] $C,

    [Parameter(Mandatory = $false)]
    [string] $N
  )

  if ($T) {
      Write-Warning "prep T switch"
      $null = Copy-Item -Force -Recurse -Exclude .git "${PackageSourcesPath}\*" "${PackageBuildPath}"

  } else {
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    $Archive = Get-ChildItem -Filter *.zip $PackageSourcesPath
    $ArchivePath = $Archive.FullName

    switch ($PSBoundParameters) {

      C {
        $DirectoryPath = New-Item -Force -ItemType Directory (Join-Path $PackageBuildPath $C)
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $DirectoryPath)
      }

      N {
        Set-Variable -Scope 1 -Name PackageBuildPath -Value (Join-Path $BuildPath $C)
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $PackageBuildPath)
      }

      default {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $PackageBuildPath)
      }

    }

  }

}
