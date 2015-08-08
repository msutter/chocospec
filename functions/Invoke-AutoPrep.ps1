function Invoke-AutoPrep {
<#
.SYNOPSIS

.DESCRIPTION
Script commands to "prepare" the program (e.g. to uncompress it) so that it will be ready for building.
Typically this is just "%autosetup"; a common variation is "%autosetup -n NAME" if the source file unpacks into NAME.
See the %prep section below for more.

.EXAMPLE

#>
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $false)]
    [switch] $D,

    [Parameter(Mandatory = $false)]
    [int] $SourceIndex = 0
  )

  $source = $sources[$SourceIndex]

  switch ($source.type) {
    httprepo {

      $SourceFile = $source.file
      $SourcePath = Join-Path "${SourcesPath}" $SourceFile
      $SourceExtension = $SourcePath.split('.')[-1]

      if (!$D) {
        $null = Remove-Item -Force -Recurse $PackageBuildPath
      }

      if ($SourceExtension -eq 'zip') {

        Write-Verbose "Source file is a zip archive"
        [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
        $ArchivePath = $SourcePath

        # Inspecting the zip file
        $Zip = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)

        $EntriesBasePathes = @()
        foreach ($ZipEntry in $Zip.Entries) {
          # check basepath for each file
          Write-Verbose "ZipEntry.FullName: $($ZipEntry.FullName)"
          $EntriesBasePathes += $ZipEntry.FullName.split('/')[0]
        }

        $BasePathes       = ($EntriesBasePathes | select -unique)
        $BasePathIsUnique = $BasePathes.count -eq 1
        $BasePathisValid  = $BasePathes -eq $PackageDirectoryName

        # Add Pathes infos
        Write-Verbose "BasePathes: ${BasePathes}"
        Write-Verbose "BasePathIsUnique: ${BasePathIsUnique}"
        Write-Verbose "BasePathisValid: ${BasePathisValid}"

        if (!$BasePathIsUnique) {
          # Create the directory and unpack in it
          Write-Verbose "Zip Content has no base directory ! Creating ${PackageDirectoryName} as base directory"
          $null = New-Item -Force -ItemType Directory $PackageBuildPath
          $null = [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $PackageBuildPath)

        } elseIf ($BasePathIsUnique -and !$BasePathisValid) {
          # Unpack the zip and rename the invalid base folder
          Write-Verbose "Zip Content has an invalid base directory ! Renaming ${BasePathes} to ${PackageDirectoryName} as base directory"
          [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $BuildPath)
          Rename-Item (Join-Path $BuildPath $BasePathes) $PackageBuildPath

        } elseif ($BasePathIsUnique -and $BasePathisValid) {
          Write-Verbose "Zip Content has a valid base directory"
          # Unpack (should create the PackageBuild Directory)
          $null = [System.IO.Compression.ZipFile]::ExtractToDirectory($ArchivePath, $BuildPath)

        }

      } else {
        Write-Verbose "Source file is not a zip archive"
        $null = New-Item -Force -ItemType Directory $PackageBuildPath
        # $null = Copy-Item -Force -Recurse "${SourcePath}" "${PackageBuildPath}"
        $null = Robocopy "${SourcePath}" "${PackageBuildPath}" /E
      }
    } # httprepo

    git {
        Write-Verbose "Source is a git repo"
        $RepoName = ($source.url.split('/')[-1]) -replace '.git$', ''
        Write-Verbose "Git repo name: ${RepoName}"

        $SourcePath = Join-Path "${SourcesPath}" $RepoName
        $null = New-Item -Force -ItemType Directory $PackageBuildPath
        #$null = Get-ChildItem "${SourcePath}" -Exclude .git | Copy-Item -Force -Recurse -Destination "${PackageBuildPath}"
        $null = Robocopy "${SourcePath}" "${PackageBuildPath}" /E /XD .git
    } # git

  } # switch
}
