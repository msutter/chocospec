function New-TempDirectory
{
   $TempPath = [System.IO.Path]::GetTempPath()
   $TempDirectoryName = [System.Guid]::NewGuid().ToString()
   $TempDirectoryPath = Join-Path $TempPath $TempDirectoryName

   $null = New-Item -ItemType Directory $TempDirectoryPath

   $TempDirectoryPath
}