function Get-ChocoSpec {
<#
.SYNOPSIS

Gets the chocospec

.DESCRIPTION

Gets the chocospec

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    # Specifies the location of the generated nupkg file
    [ValidateScript( { Test-Path($_) } ) ]
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
    [string]$Path
  )

  Process {

    # Set chocospec absolute path
    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    # Load the spec file
    $chocospec = Get-Yaml -FromFile $AbsPath
    $Result = $chocospec.Clone()

    # Alowed params
    $AllowedKeys = @(
      'id',
      'title',
      'version',
      'authors',
      'owners',
      'projectUrl',
      'requireLicenseAcceptance',
      'summary',
      'description',
      'tags',
      'dependencies',
      'releaseNotes',
      'sources',
      'setup',
      'prefix',
      'ChocolateyBeforeInstall',
      'ChocolateyInstall',
      'ChocolateyAfterInstall',
      'ChocolateyBeforeUninstall',
      'ChocolateyUninstall',
      'ChocolateyAfterUninstall',
      'installers',
      'uninstallers'
    )

    # Mandatory keys
    $MandatoryKeys = @(
      'id',
      'version',
      'authors',
      'description'
    )

    # Check Allowed params
    foreach ($Key in $Chocospec.Keys ) {
      # Validity check
      if (!($AllowedKeys -Contains $Key)) {
        Write-Error "Parameter '${Key}' not valid"
        throw
      }
      # Empty check
      if (!$($Chocospec.$Key)) {
        Write-Warning "Parameter '${Key}' is empty, removing it from result"
        $Result.Remove($Key)
      }
    }

    # Check mandatory params
    foreach ($MandatoryKey in $MandatoryKeys) {
      if (!$chocospec.ContainsKey($MandatoryKey)) {
        Write-Error "Mandatory parameter '${MandatoryKey}' not found in the chocospec file"
        throw
      }
    }

    Return $Result
  }

}