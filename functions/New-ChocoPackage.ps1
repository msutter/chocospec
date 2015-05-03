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
  [string] $prep,

  [Parameter(Mandatory = $false)]
  [string] $build,

  [Parameter(Mandatory = $false)]
  [string] $install,

  [Parameter(Mandatory = $false)]
  [string] $check,

  [Parameter(Mandatory = $false)]
  [string] $clean,

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

    $chocoBuildPathes = New-ChocoSpecBuildEnvironment `
      -Path           $AbsBuildSpace `
      -PackageId      $id `
      -PackageVersion $version

    # Create variables as contained the Pathes in scriptKey
    foreach ($NewVar in $chocoBuildPathes.Keys) {
      New-Variable -Name $NewVar -Value $chocoBuildPathes.$NewVar
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
    $null = New-ChocoManifest -OutputDirectory $PackageBuildRootToolsPath @ChocoParams

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
        "$(Get-Variable -Name $scriptKey -valueOnly)" | Out-File -filepath "${PackageBuildRootToolsPath}\${scriptKey}.ps1"

      } else {
        if ($templateScriptsKeys.Contains($scriptKey)) {
          # if no install(uninstall) script given use the templates
          $null = Copy-ChocoToolsScripts -ToolsDirectory $PackageBuildRootToolsPath -ScriptKeys $scriptKey
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

    # Update nuspec for chocolatey files folder
    $PackageRootfiles = @(
      @{
        src = "${FilesDirectoryName}\**";
        target = 'files'
      }
    )

    Update-Nuspec -Path $NuspecPath -files $PackageRootfiles

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
            $Filename = $source.file
            $FilePath = Join-Path $SourcesPath $Filename

            if ($source.url) {
              $FullUrl  = "$($source.url)"
            } else {
              $FullUrl  = "${HttpRepoHost}/$($source.path)"
            }

            Write-Verbose "Downloading ${Filename} from ${HttpRepoHost}"
            Invoke-WebRequest -Uri $FullUrl -OutFile $FilePath
          }

          git {
            Write-Verbose "Cloning $($source.url) into ${SourcesPath}"
            $Location = Get-Location
            Set-Location "${SourcesPath}"
            $null = & "${GitCommand}" clone $source.url 2>&1
            Set-Location "${Location}"
          }

          local {
            Write-Verbose "Copying $($source.path) into ${SourcesPath}"
            $null = Copy-Item -Force "$($source.path)" "${SourcesPath}/."
          }
        }
      }
    }

    ############################################################################
    #
    # prep
    #
    # This reads the sources and patches in the source directory.
    # It unpackages the sources to a subdirectory underneath the
    # build directory and applies the patches.
    #
    # source directory: ${SourcesPath}
    # build directory: ${PackageBuildPath}
    #
    ############################################################################
    $PrepScriptFilePath = New-ChocoBuildScript `
      -Type               'Prep' `
      -PackageScriptsPath $PackageScriptsPath `
      -Content            $prep

    $null = & "${PrepScriptFilePath}"

    ############################################################################
    #
    # build
    #
    # This compiles the files underneath the build directory
    #
    # build directory: ${PackageBuildPath}
    #
    ############################################################################
    $BuildScriptFilePath = New-ChocoBuildScript `
      -Type               'Build' `
      -PackageScriptsPath $PackageScriptsPath `
      -Content            $build

    $null = & "${BuildScriptFilePath}"

    ############################################################################
    #
    # install
    #
    # This reads the files underneath the build directory %_builddir and writes
    # to a directory underneath the build root directory %_buildrootdir.
    # The files that are written are the files that are supposed to be installed
    # when the binary package is installed by an end-user.
    #
    # Beware of the weird terminology: The build root directory is not the same
    # as the build directory.
    #
    # build directory: ${PackageBuildPath}
    # root directory: ${PackageRoorPath}
    #
    ############################################################################
    $InstallScriptFilePath = New-ChocoBuildScript `
      -Type               'Install' `
      -PackageScriptsPath $PackageScriptsPath `
      -Content            $install

    $null = & "${InstallScriptFilePath}"

    ############################################################################
    # Check
    #
    # Check that the software works properly.
    # This is often implemented by running some variation of "make test".
    # Many packages don't implement this stage.
    #
    ############################################################################
    $CheckScriptFilePath = New-ChocoBuildScript `
      -Type               'Check' `
      -PackageScriptsPath $PackageScriptsPath `
      -Content            $check

    $null = & "${CheckScriptFilePath}"


    #############################################################
    # Generate the package
    #############################################################
    New-NuPkg `
      -NuspecPath       $NuspecPath `
      -BasePath         $PackageBuildRootPath `
      -OutputDirectory  $NupkgsPath `
      -Verbose

    $null = Copy-Item $NupkgsPath/*.nupkg $AbsOutputDirectory

    #############################################################
    # Clean
    #############################################################
    $CleanScriptFilePath = New-ChocoBuildScript `
      -Type               'Clean' `
      -PackageScriptsPath $PackageScriptsPath `
      -Content            $clean

    $null = & "${CleanScriptFilePath}"

    #############################################################
    # Clean the build space directory if temp generated
    #############################################################

    if (!$PSBoundParameters.ContainsKey('BuildSpace')) {
      Write-Verbose "Removing Temporary BuildSpace: ${AbsBuildSpace}"
      Remove-Item -Force -Recurse $AbsBuildSpace
    }

  }
}