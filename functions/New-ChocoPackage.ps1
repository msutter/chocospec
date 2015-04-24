function New-ChocoPackage {
<#
.SYNOPSIS

Creates a chocolatey package

.DESCRIPTION

Creates a chocolatey package

.EXAMPLE

#>
[CmdletBinding()]
Param
(

  # Specifies the location of the generated nupkg file
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true )]
  [string]$OutputDirectory = (Get-Location),

  # Specifies the location of build
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false )]
  [string]$BuildSpace = (New-TempDirectory),

  # If specified. Overrides the httprepo host Value
  # Usefull for CICD jobs on different envirements
  [Parameter(Mandatory = $false)]
  [string]$HttpRepoOverride,

  # Git command
  [Parameter(Mandatory = $false)]
  [string]$GitCommand = 'C:\Program Files (x86)\Git\bin\git.exe',

  ## Nuspec params

  # Specifies the id
  [Parameter(Mandatory = $true)]
  [string] $id,

  # Specifies the version
  [Parameter(Mandatory = $true)]
  [string] $version,

  # Specifies the titleversion
  [Parameter(Mandatory = $false)]
  [string] $title,

  # Specifies the authors
  [Parameter(Mandatory = $true)]
  [string[]] $authors,

  # Specifies the owners
  [Parameter(Mandatory = $false)]
  [string[]] $owners,

  # Specifies the description
  [Parameter(Mandatory = $true)]
  [string] $description,

  # Specifies the releaseNotes
  [Parameter(Mandatory = $false)]
  [string] $releaseNotes,

  # Specifies the summary
  [Parameter(Mandatory = $false)]
  [string] $summary,

  # Specifies the language
  [Parameter(Mandatory = $false)]
  [string] $language,

  # Specifies the projectUrl
  [Parameter(Mandatory = $false)]
  [string] $projectUrl,

  # Specifies the iconUrl
  [Parameter(Mandatory = $false)]
  [string] $iconUrl,

  # Specifies the licenseUrl
  [Parameter(Mandatory = $false)]
  [string] $licenseUrl,

  # Specifies the copyright
  [Parameter(Mandatory = $false)]
  [string] $copyright,

  # Specifies the requireLicenseAcceptance
  [Parameter(Mandatory = $false)]
  [string] $requireLicenseAcceptance,

  # Specifies the tags
  [Parameter(Mandatory = $false)]
  [string[]] $tags,

  # Specifies the dependencies
  [Parameter(Mandatory = $false)]
  [hashtable[]] $dependencies,

  [Parameter(Mandatory = $false)]
  [hashtable[]] $files,

  ## Choco params

  [Parameter(Mandatory = $false)]
  [hashtable[]] $sources,

  [Parameter(Mandatory = $false)]
  [string] $setup,

  [Parameter(Mandatory = $false)]
  [string] $prefix,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyInstall,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyBeforeInstall,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyAfterInstall,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyUninstall,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyBeforeUninstall,

  [Parameter(Mandatory = $false)]
  [string] $ChocolateyAfterUninstall,

  [Parameter(Mandatory = $false)]
  [hashtable[]] $installers,

  [Parameter(Mandatory = $false)]
  [hashtable[]] $uninstallers
)

  Begin {}

  Process {

    $MyModulePath = Split-Path -Parent $PSScriptRoot
    Write-Verbose "MyModulePath: ${MyModulePath}"

    # Set outputdir absolute path
    if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
        $AbsOutputDirectory = $OutputDirectory
    } else {
        $AbsOutputDirectory = Join-Path (Get-Location) $OutputDirectory
    }

    # Set build absolute path
    if ([System.IO.Path]::IsPathRooted($BuildSpace)) {
        $AbsBuildSpace = $BuildSpace
    } else {
        $AbsBuildSpace = Join-Path (Get-Location) $BuildSpace
    }

    ###################### Build Environment dirs ######################

    $ChocoSpecBuildVars = New-ChocoSpecBuildEnvironment $AbsBuildSpace -PackageId $id

    # Create variables as contained the Pathes in scriptKey
    foreach ($NewVar in $ChocoSpecBuildVars.Keys) {
      New-Variable -Name $NewVar -Value $ChocoSpecBuildVars.$NewVar
    }

    ###################### Nuspec Generation ######################

    $NuspecFileName = $id + ".nuspec"
    Write-Verbose "NuspecFileName: ${NuspecFileName}"

    $NuspecPath = Join-Path $SpecsPath $NuspecFileName

    $NuspecParams = @{}

    $null = $NuspecParams.Add('id', $id )
    $null = $NuspecParams.Add('version', $version )
    $null = $NuspecParams.Add('authors', $authors -Join ', ')
    $null = $NuspecParams.Add('description', $description)

    if (![string]::IsNullOrEmpty($title)) {
      $null = $NuspecParams.Add('title', $title)
    }

    if (![string]::IsNullOrEmpty($summary)) {
      $null = $NuspecParams.Add('summary', $summary)
    }

    if (![string]::IsNullOrEmpty($language)) {
      $null = $NuspecParams.Add('language', $language)
    }

    if (![string]::IsNullOrEmpty($projectUrl)) {
      $null = $NuspecParams.Add('projectUrl', $projectUrl)
    }

    if (![string]::IsNullOrEmpty($iconUrl)) {
      $null = $NuspecParams.Add('iconUrl', $iconUrl)
    }

    if (![string]::IsNullOrEmpty($licenseUrl)) {
      $null = $NuspecParams.Add('licenseUrl', $licenseUrl)
    }

    if (![string]::IsNullOrEmpty($copyright)) {
      $null = $NuspecParams.Add('copyright', $copyright)
    }

    if (![string]::IsNullOrEmpty($requireLicenseAcceptance)) {
      $null = $NuspecParams.Add('requireLicenseAcceptance', $requireLicenseAcceptance)
    }

    if (![string]::IsNullOrEmpty($owners)) {
      $null = $NuspecParams.Add('owners', $owners -Join ', ')
    }

    if (![string]::IsNullOrEmpty($tags)) {
      $null = $NuspecParams.Add('tags', $tags -Join ' ')
    }

    if (![string]::IsNullOrEmpty($dependencies)) {
      $null = $NuspecParams.Add('dependencies', $dependencies)
    }

    # Generate the Nuspec
    New-Nuspec -Path $NuspecPath @NuspecParams -Verbose

    #############################################################
    # Package Choco Tools
    #############################################################

    # Choco Manifest Generation
    $ChocoParams = @{}

    $null = $ChocoParams.Add('Id', $id)

    if ($prefix) {
      $null = $ChocoParams.Add('Prefix', $prefix)
    }
    if ($installers) {
      $null = $ChocoParams.Add('Installers', $installers)
    }
    if ($uninstallers) {
      $null = $ChocoParams.Add('Uninstallers', $uninstallers)
    }

    # Generate the Choco Manifest
    $null = New-ChocoManifest -OutputDirectory $PackageToolsPath @ChocoParams

    # Add Install/Uninstall custom scripts
    $scriptskeys = @(
      'chocolateyInstall',
      'chocolateyUninstall',
      'chocolateyBeforeInstall',
      'chocolateyAfterInstall',
      'chocolateyBeforeUninstall',
      'chocolateyAfterUninstall'
    )

    $templateScriptsKeys = @(
      'chocolateyInstall',
      'chocolateyUninstall'
    )

    $FilesPath = "$MyModulePath/files"

    foreach ($scriptKey in $scriptskeys) {
      if ($PSBoundParameters.ContainsKey($scriptKey)) {
        Write-Verbose "${scriptKey}: ${PackageToolsPath}\${scriptKey}.ps1"
        "$(Get-Variable -Name $scriptKey -valueOnly)" | Out-File -filepath "${PackageToolsPath}\${scriptKey}.ps1"

      } else {
        if ($templateScriptsKeys.Contains($scriptKey)) {
          # if no install(uninstall) script given use the templates
          $null = Copy-ChocoToolsScripts -ToolsDirectory $PackageToolsPath -ScriptKeys $scriptKey
        }
      }
    }

    # Update nuspec for chocolatey tools folder
    $ChocoToolsfiles = @(
      @{
        src = "${ToolsDirectoryName}\**";
        target = 'tools'
      }
    )

    Update-Nuspec -Path $NuspecPath -files $ChocoToolsfiles

    #############################################################
    # Package Sources
    #############################################################

    # Get sources
    if ($sources) {
      foreach ($source in $sources) {
        switch ($source.type)
        {

          httprepo {
            if ($PSBoundParameters.ContainsKey('HttpRepoOverride')) {
              $HttpRepoHost = $HttpRepoOverride
            } else {
              $HttpRepoHost = $source.host
            }
            $Filename = $source.path.split('/')[-1]
            $FilePath = Join-Path $PackageSourcesPath $Filename
            $FullUrl = "${HttpRepoHost}/$($source.path)"
            Write-Verbose "Downloading ${Filename} from ${HttpRepoHost}"
            $webclient = New-Object System.Net.WebClient
            $webclient.DownloadFile($FullUrl, $FilePath)
          }

          git {
            Write-Verbose "Cloning $($source.url) into ${PackageSourcesPath}"
            $null = & "${GitCommand}" clone $source.url "${PackageSourcesPath}" 2>&1
          }

          local {
            Write-Verbose "Copying $($source.path) into ${PackageSourcesPath}"
            $null = Copy-Item -Force "$($source.path)/*" "${PackageSourcesPath}"
          }
        }
      }
    }

    #############################################################
    # Package Root
    #############################################################

    $SetupScriptFileName = 'chocolateySetup.ps1'
    $SetupScriptFilePath = Join-Path $PackageBuildPath $SetupScriptFileName

    # if (Test-Path $PackageRootPath) {
    #   $null = Remove-Item -Force -Recurse $PackageRootPath
    # }
    # $null = New-Item -ItemType Directory -Path $PackageRootPath

    if ($setup) {
      Write-Verbose 'Executing setup:'
      Write-Verbose "$($setup)"
      "$($setup)" | Out-File -filepath $SetupScriptFilePath
    } else {
      Write-Verbose 'Executing default setup'
      "`$null = Copy-Item -Force -Recurse -Exclude .git `"`${PackageSourcesPath}\*`" `"`${PackageRootPath}`"" | Out-File -filepath $SetupScriptFilePath
      Write-Verbose (Get-Content $SetupScriptFilePath)
    }
    Write-Verbose "SetupScriptFilePath: ${SetupScriptFilePath}"
    $null = & "${SetupScriptFilePath}"

    # Update nuspec for chocolatey tools folder
    $PackageRootfiles = @(
      @{
        src = "${RootDirectoryName}\**";
        target = 'files'
      }
    )

    Update-Nuspec -Path $NuspecPath -files $PackageRootfiles

    #############################################################
    # Generate the package
    #############################################################
    New-NuPkg -NuspecPath $NuspecPath -BasePath $PackageBuildPath -OutputDirectory $NupkgsPath -Verbose
    $null = Copy-Item $NupkgsPath/*.nupkg $AbsOutputDirectory

    #############################################################
    # Clean the temp build directory
    #############################################################

    if (!$PSBoundParameters.ContainsKey('BuildSpace')) {
      Write-Verbose "Removing Temporary BuildSpace: ${AbsBuildSpace}"
      Remove-Item -Force -Recurse $AbsBuildSpace
    }

  }
}