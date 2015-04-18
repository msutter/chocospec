function New-ChocoPackage {
<#
.SYNOPSIS

Creates a chocolatey package from a chocospec file

.DESCRIPTION

Creates a chocolatey package from a chocospec file

.EXAMPLE

#>
[CmdletBinding()]
Param
(

  # Specifies the chocospec file
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
  $Chocospec,

  # Specifies the location of the generated nupkg file
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
  [string]$OutputDirectory = (Get-Location),

  # Specifies the location of build
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false )]
  [string]$BuildDirectory = (New-TempDirectory)

)

  # Set chocospec absolute path
  if ([System.IO.Path]::IsPathRooted($Chocospec)) {
      $AbsChocospec = $Chocospec
  } else {
      $AbsChocospec = Join-Path (Get-Location) $Chocospec
  }

  # Set outputdir absolute path
  if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
      $AbsOutputDirectory = $OutputDirectory
  } else {
      $AbsOutputDirectory = Join-Path (Get-Location) $OutputDirectory
  }

  # Set build absolute path
  if ([System.IO.Path]::IsPathRooted($BuildDirectory)) {
      $AbsBuildDirectory = $BuildDirectory
  } else {
      $AbsBuildDirectory = Join-Path (Get-Location) $BuildDirectory
  }

  Write-Verbose "BuildDirectory: ${AbsBuildDirectory}"

  # Load the spec file
  $chocospec = Get-Yaml -FromFile $AbsChocospec

  # Mandatory keys
  $MandatoryKeys = @(
    'id',
    'version',
    'authors',
    'description'
  )

  # Check mandatory params
  foreach ($MandatoryKey in $MandatoryKeys) {
    if (!$chocospec.ContainsKey($MandatoryKey)) {
      Write-Error "Mandatory parameter '${MandatoryKey}' not found in the chocospec file"
      throw
    }
  }

  ###################### Nuspec Generation ######################

  $NuspecFileName = $chocospec.id + ".nuspec"
  Write-Verbose "NuspecFileName: ${NuspecFileName}"

  $NuspecPath = Join-Path $AbsBuildDirectory $NuspecFileName

  $NuspecParams = @{}
  $null = $NuspecParams.Add('id', $chocospec.id )
  $null = $NuspecParams.Add('version', $chocospec.version )
  $null = $NuspecParams.Add('authors', $chocospec.authors -Join ', ')
  $null = $NuspecParams.Add('description', $chocospec.description)

  if ($chocospec.title) {
    $null = $NuspecParams.Add('title', $chocospec.title)
  }
  if ($chocospec.summary) {
    $null = $NuspecParams.Add('summary', $chocospec.summary)
  }
  if ($chocospec.language) {
    $null = $NuspecParams.Add('language', $chocospec.language)
  }
  if ($chocospec.projectUrl) {
    $null = $NuspecParams.Add('projectUrl', $chocospec.projectUrl)
  }
  if ($chocospec.iconUrl) {
    $null = $NuspecParams.Add('iconUrl', $chocospec.iconUrl)
  }
  if ($chocospec.licenseUrl) {
    $null = $NuspecParams.Add('licenseUrl', $chocospec.licenseUrl)
  }
  if ($chocospec.copyright) {
    $null = $NuspecParams.Add('copyright', $chocospec.copyright)
  }
  if ($chocospec.requireLicenseAcceptance) {
    $null = $NuspecParams.Add('requireLicenseAcceptance', $chocospec.requireLicenseAcceptance)
  }

  if ($chocospec.owners) {
    $null = $NuspecParams.Add('owners', $chocospec.owners -Join ', ')
  }
  if ($chocospec.title) {
    $null = $NuspecParams.Add('tags', $chocospec.tags -Join ' ')
  }

  # Generate the Nuspec
  New-Nuspec -Path $NuspecPath @NuspecParams -Verbose

  #############################################################
  # Choco Install/Uninstall Scripts Generation
  #############################################################

  $ChocolateyToolsDirectoryName = 'chocolateyTools'
  $ChocolateyToolsPath = Join-Path $AbsBuildDirectory $ChocolateyToolsDirectoryName

  # Clean
  if (Test-Path $ChocolateyToolsPath) {
    $null = Remove-Item -Force -Recurse $ChocolateyToolsPath
  }

  $null = New-Item -ItemType Directory -Path $ChocolateyToolsPath

  $null = Copy-ChocoToolsScripts -ToolsDirectory $ChocolateyToolsPath

  # Choco Manifest Generation

  $NuspecPath = Join-Path $AbsBuildDirectory $NuspecFileName

  $ChocoParams = @{}

  $null = $ChocoParams.Add('Id', $chocospec.id)

  if ($chocospec.prefix) {
    $null = $ChocoParams.Add('Prefix', $chocospec.prefix)
  }
  if ($chocospec.installers) {
    $null = $ChocoParams.Add('Installers', $chocospec.installers)
  }
  if ($chocospec.uninstallers) {
    $null = $ChocoParams.Add('Uninstallers', $chocospec.uninstallers)
  }

  # Generate the Choco Manifest
  $null = New-ChocoManifest -OutputDirectory $ChocolateyToolsPath @ChocoParams -Verbose

  # Update nuspec for chocolatey tools folder
  $ChocoToolsfiles = @(
    @{
      src = "${ChocolateyToolsDirectoryName}\**";
      target = 'tools'
    }
  )

  Update-Nuspec -Path $NuspecPath -files $ChocoToolsfiles

  #############################################################
  # Package Root Generation
  #############################################################

  $PackageRootDirectoryName = 'packageRoot'
  $PackageRootPath = Join-Path $AbsBuildDirectory $PackageRootDirectoryName

  if (Test-Path $PackageRootPath) {
    $null = Remove-Item -Force -Recurse $PackageRootPath
  }

  $null = New-Item -ItemType Directory -Path $PackageRootPath

  # Add sources to packageRoot
  if ($chocospec.sources) {
    foreach ($source in $chocospec.sources) {
      $Filename = $source.url.split('/')[-1]
      $FilePath = Join-Path $PackageRootPath $Filename

      Write-Verbose "Downloading ${Filename} from $($source.url)"

      $webclient = New-Object System.Net.WebClient
      $webclient.DownloadFile($source.url, $FilePath)
    }
  }

  # Update nuspec for chocolatey tools folder
  $PackageRootfiles = @(
    @{
      src = "${PackageRootDirectoryName}\**";
      target = 'files'
    }
  )

  Update-Nuspec -Path $NuspecPath -files $PackageRootfiles

  #############################################################
  # Generate the package
  #############################################################
  New-NuPkg -NuspecPath $NuspecPath -BasePath $AbsBuildDirectory -OutputDirectory $OutputDirectory -Verbose

  #############################################################
  # Clean the temp build directory
  #############################################################

  if (!$PSBoundParameters.ContainsKey('BuildDirectory')) {
    Write-Verbose "Removing Temporary BuildDirectory: ${AbsBuildDirectory}"
    Remove-Item -Force -Recurse $AbsBuildDirectory
  }

}