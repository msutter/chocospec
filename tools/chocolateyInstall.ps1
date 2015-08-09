$packageName = "chocoSpec"
$moduleName = "chocoSpec"

try {
  $installDir = Join-Path $PSHome "Modules"
  $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  $pkgpath = (get-item $myDir).parent.FullName
  $psmodulepath = "$pkgpath/files"
  $null = Copy-Item "${psmodulepath}" "${installDir}/${modulename}" -Recurse -Force

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}

