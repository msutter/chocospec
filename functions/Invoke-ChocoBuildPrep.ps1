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
    [string] $N,

    [Parameter(Mandatory = $false)]
    [switch] $C,

    [Parameter(Mandatory = $false)]
    [switch] $D,

    [Parameter(Mandatory = $false)]
    [int] $SourceIndex = 0
  )

    $SourcePath = "${SourcesPath}\$($sources[$SourceIndex].file)"

    if (!$D) {
      $null = Remove-Item -Force -Recurse $PackageBuildPath
    }

    if ($T) {

        $null = New-Item -Force -ItemType Directory $PackageBuildPath
        $null = Copy-Item -Force -Recurse -Exclude .git "${SourcePath}" "${PackageBuildPath}"
    } else {

      [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
      $ArchivePath = $SourcePath
      Write-Verbose "ArchivePath: ${ArchivePath}"

      if ($C) {
        # Create the directory and unpack in it
        $null = New-Item -Force -ItemType Directory $PackageBuildPath
        $null = [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $PackageBuildPath)

      } elseIf ($PSBoundParameters.ContainsKey('N')) {

        [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $BuildPath)
        Rename-Item (Join-Path $BuildPath $N) $PackageBuildPath

      } else {
        # Unpack (should create the PackageBuild Directory)
        $null = [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $BuildPath)

      }

    }

}


