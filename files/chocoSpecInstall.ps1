#------- INSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Import chocolateyPkgHelpers Module
  #Import-Module -Name chocoHelpers -Force
  Import-Module -force -verbose -Name c:\powershell\chocohelpers\chocohelpers.psm1

  # Load Package variables (datas)
  $ChocoManifestData = Import-ChocoHelpersVariables -PackagePath "${PackagePath}"

  # Add the datas as local variable
  Write-Verbose '------- Variable you can use in the chocospec --------'

  foreach ($Var in $ChocoManifestData.Keys) {
      Write-Verbose "${Var}: $($ChocoManifestData.$Var)"
      # Pathes with spaces workaround
      if ($ChocoManifestData.$Var -is [system.string]) {
          Set-Variable -Name $Var -Value "$($ChocoManifestData.$Var)"
      } else {
          Set-Variable -Name $Var -Value $ChocoManifestData.$Var
      }
  }

  Write-Verbose '------------------------------------------------------'

  #------- EXECUTE BEFORE-INSTALL SCRIPT WHEN PRESENT ---------#
  $BeforeInstallPath = "${ToolsPath}\chocolateyBeforeInstall.ps1"
  if (Test-Path -Path "${BeforeInstallPath}") {
    Write-Verbose "Executing ${BeforeInstallPath}"
    & "${BeforeInstallPath}" `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- INSTALLATION SETUP (Only files deployement here ) ---------#
  if ( Test-Path variable:Prefix ) {
    Install-ChocoPkgFiles `
      -Prefix $Prefix `
      -FilesPath $FilesPath `
      -PackageId $PackageId `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- EXECUTE AFTER-INSTALL SCRIPT ---------#
  $AfterInstallPath = "${ToolsPath}\chocolateyAfterInstall.ps1"
  if (Test-Path -Path "${AfterInstallPath}") {
    Write-Verbose "Executing ${AfterInstallPath}"
    & "${AfterInstallPath}" `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  } else {
    # Default install of exe, msi, etc...
    Install-ChocoPkgInstallers `
      -Installers $Installers `
      -FilesPath $FilesPath `
      -PackageId $PackageId `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $PackageId
} catch {
  Write-ChocolateyFailure $PackageId $($_.Exception.Message)
  throw
}
