#------- INSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Import chocolateyPkgHelpers Module
  Import-Module -Name chocoHelpers

  # Load Package variables (datas)
  Import-ChocoHelpersVariables -PackagePath "${PackagePath}"

  #------- EXECUTE BEFORE-INSTALL SCRIPT WHEN PRESENT ---------#
  $BeforeInstallPath = "${ToolsPath}\chocolateyBeforeInstall.ps1"
  if (Test-Path -Path "${BeforeInstallPath}") {
    Write-Verbose "Executing ${BeforeInstallPath}"
    & "${BeforeInstallPath}"
  }

  #------- INSTALLATION SETUP (Only files deployement here ) ---------#
  Install-ChocoPkgFiles

  #------- EXECUTE AFTER-INSTALL SCRIPT ---------#
  $AfterInstallPath = "${ToolsPath}\chocolateyAfterInstall.ps1"
  if (Test-Path -Path "${AfterInstallPath}") {
    Write-Verbose "Executing ${AfterInstallPath}"
    & "${AfterInstallPath}"
  } else {
    # Default install of exe, msi, etc...
    Install-ChocoPkgInstallers
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $PackageId
} catch {
  Write-ChocolateyFailure $PackageId $($_.Exception.Message)
  throw
}
