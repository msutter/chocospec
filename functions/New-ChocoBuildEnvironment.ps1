function New-ChocoSpecBuildEnvironment {
    <#
    .SYNOPSIS

    .DESCRIPTION

    #>
    [CmdletBinding()]
    Param
    (
        # Specifies the path
        [ValidateScript( { Test-Path($_) } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [string]$Path,

        # PackageId
        [Parameter(Mandatory = $false)]
        [string]$PackageID,

        # PackageId
        [Parameter(Mandatory = $false)]
        [string]$PackageVersion,

        # Clean if exists
        [Parameter(Mandatory = $false)]
        [switch]$Clean

    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Resolve-Path (Join-Path (Get-Location) $Path)
    }

    # Environment specific

    $BuildPath      = Join-Path $AbsPath 'BUILD'
    $BuildRootPath  = Join-Path $AbsPath 'BUILDROOT'
    $NupkgsPath     = Join-Path $AbsPath 'NUPKGS'
    $SpecsPath      = Join-Path $AbsPath 'NUSPECS'
    $PartsPath = Join-Path $AbsPath 'PARTS'
    $ScriptsPath    = Join-Path $AbsPath 'SCRIPTS'
    $SourcesPath    = Join-Path $AbsPath 'SOURCES'

    $BuildPathes = @{
      ScriptsPath   = $ScriptsPath;
      SpecsPath     = $SpecsPath;
      SourcesPath   = $SourcesPath;
      BuildPath     = $BuildPath;
      BuildRootPath = $BuildRootPath;
      NupkgsPath    = $NupkgsPath;
      PartsPath     = $PartsPath
    }

    $BuildPathArray = $BuildPathes.Values | Sort

    foreach ($PathItem in $BuildPathArray) {
      if ( Test-Path $PathItem ) {
      } else {
        $null = New-Item -ItemType Directory -Path $PathItem
      }
    }

    # Package specific

    if ($PSBoundParameters.ContainsKey('PackageID')) {

      if ($PSBoundParameters.ContainsKey('PackageVersion')) {
        $PackageDirectoryName = "${PackageID}-${PackageVersion}"
      } else {
        $PackageDirectoryName = "${PackageID}"
      }

      $ToolsDirectoryName = 'TOOLS'
      $FilesDirectoryName = 'FILES'

      $PackageBuildDirectoryNames = @{
        ToolsDirectoryName   = $ToolsDirectoryName;
        FilesDirectoryName   = $FilesDirectoryName;
        PackageDirectoryName = $PackageDirectoryName
      }

      $PackageScriptsPath        = Join-Path $ScriptsPath $PackageDirectoryName
      $PackageBuildPath          = Join-Path $BuildPath $PackageDirectoryName

      $PackageBuildRootPath      = Join-Path $BuildRootPath $PackageDirectoryName
      $PackageBuildRootFilesPath = Join-Path $PackageBuildRootPath $FilesDirectoryName
      $PackageBuildRootToolsPath = Join-Path $PackageBuildRootPath $ToolsDirectoryName

      $PackagePartsPath       = Join-Path $PartsPath $PackageDirectoryName

      $PackageBuildPathes = @{
        PackageScriptsPath        = $PackageScriptsPath;
        PackageBuildPath          = $PackageBuildPath;
        PackageBuildRootPath      = $PackageBuildRootPath;
        PackageBuildRootToolsPath = $PackageBuildRootToolsPath;
        PackageBuildRootFilesPath = $PackageBuildRootFilesPath;
        PackagePartsPath     = $PackagePartsPath
      }

      $PackageBuildPathArray = $PackageBuildPathes.Values | Sort

      foreach ($PathItem in $PackageBuildPathArray) {
        if ( Test-Path $PathItem ) {
          if ($Clean) {
            $null = Remove-Item -Force -Recurse $PathItem
            Write-Verbose "${PathItem} removed (cleaned)"
            $null = New-Item -ItemType Directory -Path $PathItem
            Write-Verbose "${PathItem} created"
          } else {
            Write-Verbose "${PathItem} already exists"
          }
        } else {
          $null = New-Item -ItemType Directory -Path $PathItem
          Write-Verbose "${PathItem} created"
        }
      }

    } else {
      $PackageBuildPathes = @{}
    }

    Return ($BuildPathes + $PackageBuildPathes + $PackageBuildDirectoryNames)
}
