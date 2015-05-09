#------- UNINSTALLATION -------#
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

  #------- BEFORE UNINSTALL SCRIPT ---------#
  $BeforeUninstallPath = "${ToolsPath}\chocolateyBeforeUninstall.ps1"
  if (Test-Path -Path "${BeforeUninstallPath}") {
    Write-Verbose "Executing ${BeforeUninstallPath}"
    & "${BeforeUninstallPath}" `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  } else {
    # Default uninstall of exe, msi, etc...
    Uninstall-ChocoPkgUninstallers `
      -Uninstallers $Uninstallers `
      -FilesPath $FilesPath `
      -PackageId $PackageId `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- UNINSTALLATION SETUP ---------#
  if ( Test-Path variable:Prefix ) {
    Uninstall-ChocoPkgFiles `
      -Prefix $Prefix `
      -FilesPath $FilesPath `
      -PackageId $PackageId `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- AFTER UNINSTALL SCRIPT ---------#
  $AfterUninstallPath = "${ToolsPath}\chocolateyAfterUninstall.ps1"
  if (Test-Path -Path "${AfterUninstallPath}") {
    Write-Verbose "Executing ${AfterUninstallPath}"
    & "${AfterUninstallPath}" `
      -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #------- DONE -----------------------#
  Write-ChocolateySuccess $PackageId
} catch {
  Write-ChocolateyFailure $PackageId $($_.Exception.Message)
  throw
}
