# Default install script
Write-Verbose "Executing install"
$null = Copy-Item -Force -Recurse -Exclude .git "${PackageBuildPath}\*" "${PackageRootPath}"
