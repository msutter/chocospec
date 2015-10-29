$packageName = "chocoSpec"
$moduleName = "chocoSpec"

$installDir   = Join-Path $PSHome "Modules"
$installPath  = Join-Path $installDir $modulename
$null = Remove-Item -Recurse $installPath