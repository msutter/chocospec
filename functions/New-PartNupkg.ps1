Function New-PartNupkg
{
    [CmdletBinding()]
    Param
    (
        # Specifies the nupkg files to update
        [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.nuspec } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        [string]$NuspecPath,

        [Parameter(Mandatory = $true)]
        [Double]$MaxSizeInByte,

        [ValidateScript( { Test-Path($_) -PathType Container } )]
        [Parameter(Mandatory = $false)]
        [string]$FilesPath = './',

        [ValidateScript( { Test-Path($_) -PathType Container } )]
        [Parameter(Mandatory = $false)]
        [string]$ToolsPath = './',

        [ValidateScript( { Test-Path($_) -PathType Container } )]
        [Parameter(Mandatory = $false)]
        [string]$Workspace = './',

        [ValidateScript( {Test-Path($_) } )]
        [Parameter(Mandatory = $false)]
        [string]$NugetCommand = 'C:\ProgramData\chocolatey\chocolateyinstall\NuGet.exe'

    )
    if ([System.IO.Path]::IsPathRooted($NuspecPath))
    {
        $AbsNuspecPath = $NuspecPath
    }
    else
    {
        $AbsNuspecPath = Join-Path -Path (Get-Location) -ChildPath $NuspecPath
    }

    # Template settings
    $ModulePath              = Split-Path -Parent $PSScriptRoot
    $TemplatesDirectoryName  = 'templates'
    $TemplatePath            = Join-Path $ModulePath $TemplatesDirectoryName

    # Workspace building
    $ZipPartsFolder    = 'ZIPPARTS'
    $NuspecPartsFolder = 'NUSPECPARTS'
    $NuPkgPartsFolder  = 'NUPKGPARTS'
    $ToolsPartsFolder  = 'TOOLS'

    $ZipPartsPath = Join-Path $Workspace $ZipPartsFolder
    $NuspecPartsPath = Join-Path $Workspace $NuspecPartsFolder
    $NuPkgPartsPath  = Join-Path $Workspace $NuPkgPartsFolder
    $ToolsPartsPath  = Join-Path $Workspace $ToolsPartsFolder

    $PartsPathes = @{
      ZipPartsPath    = $ZipPartsPath;
      NuspecPartsPath = $NuspecPartsPath;
      NuPkgPartsPath  = $NuPkgPartsPath;
      ToolsPartsPath  = $ToolsPartsPath
    }

    $PartsPathesArray = $PartsPathes.Values | Sort

    foreach ($PathItem in $PartsPathesArray) {
      if ( Test-Path $PathItem ) {
      } else {
        $null = New-Item -ItemType Directory -Path $PathItem
      }
    }

    # Split files content
    Write-Verbose 'converting to zip part'
    $Convertion = ConvertTo-ZipParts $FilesPath -OutputPath $ZipPartsPath -MaxOutputSegmentSize $MaxSizeInByte
    Write-Verbose $Convertion

    Write-Verbose "NuspecPath: ${NuspecPath}"
    $OriginalSpec = Get-Nuspec $NuspecPath
    $OriginalId = $OriginalSpec.package.metadata.id
    $OriginalVersion = $OriginalSpec.package.metadata.version

    Write-Verbose "Original id: $($OriginalSpec.package.metadata.id)"

    # Initialize tools path for main package
    $MainPartToolsPartsPath = Join-Path $ToolsPartsPath "${OriginalId}.${OriginalVersion}"
    if (!(Test-Path $MainPartToolsPartsPath)) {
      New-Item -ItemType Directory $MainPartToolsPartsPath
    }

    # Copy original tools scripts
    Get-ChildItem "${ToolsPath}" | Copy-Item -Destination "${MainPartToolsPartsPath}"

    # Initialize Dependencies for the main package
    $Dependencies = @()

    # Build part packages
    ForEach ($SubZipPartFile in $Convertion.SubZipPartFiles) {
      $ZipPartFileExtension = $SubZipPartFile.Extension
      $PartNumber = $ZipPartFileExtension -replace ".z", ""

      $PartPackageId = "${OriginalId}-part${PartNumber}"
      Write-Verbose "PartPackageId: ${PartPackageId}"

      $PartSpecFileName = "${PartPackageId}.nuspec"
      $PartSpecPath = Join-Path $NuspecPartsPath $PartSpecFileName

      $PartToolsPartsPath = Join-Path $ToolsPartsPath "${PartPackageId}.${OriginalVersion}"
      if (!(Test-Path $PartToolsPartsPath)) {
        New-Item -ItemType Directory $PartToolsPartsPath
      }

      # Add install/uninstall chocolatey scripts
      Copy-ChocoToolsScripts -ToolsDirectory "${PartToolsPartsPath}"

      $NuspecParams = @{}

      $null = $NuspecParams.Add('id', $PartPackageId )
      $null = $NuspecParams.Add('version', $OriginalSpec.package.metadata.version )
      $null = $NuspecParams.Add('authors', $OriginalSpec.package.metadata.authors)
      $null = $NuspecParams.Add('tags', "${PartPackageId} part package")

      # description
      $DescriptionTemplatePath = Join-Path $TemplatePath 'part_package_description.eps'
      $DescriptionBinding = @{
        OriginalId = $OriginalId;
        PartNumber = $PartNumber
      }
      $description = New-EpsResult -f $DescriptionTemplatePath -safe -binding $DescriptionBinding
      $null = $NuspecParams.Add('description', $description)

      # $files = @(
      #   @{
      #     src = "${ZipPartsFolder}\${SubZipPartFile}"
      #     target = "PARTS"
      #   }
      # )
      # $null = $NuspecParams.Add('files', $files)

      New-Nuspec -Path $PartSpecPath @NuspecParams -Verbose

      $Files = @(
        @{
          src    = "${ToolsPartsFolder}\${PartPackageId}.${OriginalVersion}\**"
          target = "tools"
        },
        @{
          src = "${ZipPartsFolder}\${SubZipPartFile}"
          target = "parts"
        }
      )

      Update-Nuspec -Path $PartSpecPath -Files $Files

      # Choco Manifest Generation (needed for merging on install)
      $ChocoParams = @{}

      $null = $ChocoParams.Add('Id', $OriginalSpec.package.metadata.id)
      $null = $ChocoParams.Add('Version', $OriginalSpec.package.metadata.version)

      # Generate the Choco Manifest
      $null = New-ChocoManifest -OutputDirectory $PartToolsPartsPath @ChocoParams

      # Generate sub package
      New-NuPkg `
      -NuspecPath       $PartSpecPath `
      -BasePath         $Workspace `
      -OutputDirectory  $NuPkgPartsPath `
      -Verbose

      # Udate Dependencies for the main package
      $Dependencies += @{
        id      = $PartPackageId;
        version = $OriginalSpec.package.metadata.version
      }
    }

    # Build main part package
    $MainPartSpecFileName = "${OriginalId}.nuspec"
    $MainPartSpecPath = Join-Path $NuspecPartsPath $MainPartSpecFileName

    # Copy the original nuspec
    $PartSpec = $OriginalSpec.Clone()
    $PartSpec.Save($MainPartSpecPath)

    # Add the Main Part zip file
    $Files = @(
      @{
        src    = "${ToolsPartsFolder}\${OriginalId}.${OriginalVersion}\**"
        target = "tools"
      },
      @{
        src    = "${ZipPartsFolder}\$($Convertion.MainZipPartFile)"
        target = "parts"
      }
    )

    Update-Nuspec -Path $MainPartSpecPath -Files $Files -Dependencies $Dependencies -ResetFiles

    New-NuPkg `
      -NuspecPath       $MainPartSpecPath `
      -BasePath         $Workspace `
      -OutputDirectory  $NuPkgPartsPath `
      -Verbose

    return $PartsPathes
}
