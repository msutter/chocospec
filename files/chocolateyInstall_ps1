#------- INSTALLATION -------#
try {

  # Set the location of the package on disk
  $PackagePath = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

  # Import chocolateyPkgHelpers Module
  Import-Module -Name chocolateyPkgHelpers

  # Load Package Datas
  $ChocoPkgData = Get-ChocoPkgData -PackagePath $PackagePath
  Write-Host "ChocoPkgData: ${ChocoPkgData}"

  #------- EXECUTE BEFORE-INSTALL SCRIPT WHEN PRESENT ---------#
  $BeforeInstallPath = "$($ChocoPkgData.ToolsPath)\chocolateyBeforeInstall.ps1"
  if (Test-Path -Path "${BeforeInstallPath}") {
    Write-Verbose "Executing ${BeforeInstallPath}"
    & "${BeforeInstallPath}"
  }

  #------- INSTALLATION SETUP (Only files) ---------#
  Install-ChocoPkgFiles $ChocoPkgData
  Install-ChocoPkgInstallers $ChocoPkgData


  #------- EXECUTE AFTER-INSTALL SCRIPT WHEN PRESENT ---------#
  $AfterInstallPath = "$($ChocoPkgData.ToolsPath)\chocolateyAfterInstall.ps1"
  if (Test-Path -Path "${AfterInstallPath}") {
    Write-Verbose "Executing ${AfterInstallPath}"
    & "${AfterInstallPath}"
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $ChocoPkgData.PackageId
} catch {
  Write-ChocolateyFailure $ChocoPkgData.PackageId $($_.Exception.Message)
  throw
}
