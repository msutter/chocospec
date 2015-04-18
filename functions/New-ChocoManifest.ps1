function New-ChocoManifest {
<#
.SYNOPSIS

Creates a chocolatey psd1 manifest file.

.DESCRIPTION

Creates a chocolatey psd1 manifest file.

.EXAMPLE

#>
[CmdletBinding()]
Param
(
  # Specifies the Id
  [Parameter(Mandatory = $true)]
  [string] $Id,

  # Specifies the Prefix
  [Parameter(Mandatory = $false)]
  [string] $Prefix,

  # Specifies the Installers
  [Parameter(Mandatory = $false)]
  [hashtable[]] $Installers,

  # Specifies the Uninstallers
  [Parameter(Mandatory = $false)]
  [hashtable[]] $Uninstallers,

  # Specifies the location of the generated nupkg file
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false)]
  [string]$OutputDirectory = (Get-Location)
)

  $TemplatesDirectoryName = 'templates'
  $TemplateFileName       = 'chocolatey.psd1.eps'
  $ChocoManifestFileName  = 'chocolatey.psd1'

  # Set absolute path
  if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
      $AbsOutputDirectory = $OutputDirectory
  } else {
      $AbsOutputDirectory = Join-Path (Get-Location) $OutputDirectory
  }

  $AbsPath = Join-Path $AbsOutputDirectory $ChocoManifestFileName
  $ModulePath = Split-Path -Parent $PSScriptRoot
  Write-Verbose "ModulePath: ${ModulePath}"

  $TemplatePath = [System.IO.Path]::Combine($ModulePath, $TemplatesDirectoryName, $TemplateFileName)
  Write-Verbose "TemplatePath: ${TemplatePath}"

  # Update Nuspec file with provided params
  # $null = Update-Nuspec @PSBoundParameters

  # Create nuspec from template (eps module should already be loaded from psd1 ModulesRequired)
  Write-Verbose -Message "Processing $AbsPath"
  EPS-Render -f $TemplatePath -safe -binding $PSBoundParameters > $AbsPath
  Write-Verbose -Message "${AbsPath} successfully created"


}