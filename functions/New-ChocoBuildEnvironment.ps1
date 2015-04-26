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

    $ScriptsPath   = Join-Path $AbsPath 'SCRIPTS'
    $SpecsPath     = Join-Path $AbsPath 'SPECS'
    $SourcesPath   = Join-Path $AbsPath 'SOURCES'
    $BuildPath     = Join-Path $AbsPath 'BUILD'
    $BuildRootPath = Join-Path $AbsPath 'BUILDROOT'
    $NupkgsPath    = Join-Path $AbsPath 'NUPKGS'

    $BuildPathes = @{
      ScriptsPath   = $ScriptsPath;
      SpecsPath     = $SpecsPath;
      SourcesPath   = $SourcesPath;
      BuildPath     = $BuildPath;
      BuildRootPath = $BuildRootPath;
      NupkgsPath    = $NupkgsPath
    }

    $BuildPathArray = $BuildPathes.Values | Sort

    foreach ($PathItem in $BuildPathArray) {
      if ( Test-Path $PathItem ) {
      } else {
        New-Item -ItemType Directory -Path $PathItem
      }
    }

    # Package specific

    if ($PSBoundParameters.ContainsKey('PackageID')) {

      $ToolsDirectoryName = 'TOOLS'
      $RootDirectoryName  = 'ROOT'

      $PackageBuildDirectoryNames = @{
        ToolsDirectoryName = $ToolsDirectoryName;
        RootDirectoryName  = $RootDirectoryName;
      }

      $PackageScriptsPath   = Join-Path $ScriptsPath $PackageID
      $PackageSourcesPath   = Join-Path $SourcesPath $PackageID
      $PackageBuildPath     = Join-Path $BuildPath $PackageID
      $PackageBuildRootPath = Join-Path $BuildRootPath $PackageID
      $PackageRootPath      = Join-Path $PackageBuildRootPath $RootDirectoryName
      $PackageToolsPath     = Join-Path $PackageBuildRootPath $ToolsDirectoryName

      $PackageBuildPathes = @{
        PackageScriptsPath   = $PackageScriptsPath;
        PackageSourcesPath   = $PackageSourcesPath;
        PackageBuildPath     = $PackageBuildPath;
        PackageBuildRootPath = $PackageBuildRootPath;
        PackageToolsPath     = $PackageToolsPath;
        PackageRootPath      = $PackageRootPath
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
