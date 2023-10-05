param (
    [string]$InputFile,
    [string]$OutputFile
)

$shouldExit = $false
# Check if the InputFile parameter is provided
if (-not $InputFile) {
    Write-Host "Please specify a source file using -InputFile or positional parameter 1."
    $shouldExit = $true
}
# Check if the OutputFile parameter is provided
if (-not $OutputFile) {
    Write-Host "Please specify the output file using -OutputFile or positional parameter 2."
    $shouldExit = $true
}
if ($shouldExit) {
    exit
}

# Read the XML content
$inXml = [xml]$(Get-Content -Path $InputFile)
$outXml = [xml]$(Get-Content -Path $OutputFile)

$groupElement = $outXml.package.metadata.dependencies.group
$nodesToRemove = @()

# Iterate through child nodes and add them to the removal list
foreach ($childNode in $groupElement.ChildNodes) {
    $nodesToRemove += $childNode
}
# Remove nodes from the "group" element
foreach ($nodeToRemove in $nodesToRemove) {
    $groupElement.RemoveChild($nodeToRemove) | Out-Null
}

$pkgRefs = $inXml.SelectNodes('//PackageReference')
$sortedPackages = $pkgRefs | Sort-Object { $_.GetAttribute("Include") }
$comment = $outXml.CreateComment("GENERATED BY update-nuspec.ps1")
$_ = $groupElement.AppendChild($comment)
$comment = $outXml.CreateComment("This file is rebuilt every time the build succeeds. If this section changes, that's normal")
$_ = $groupElement.AppendChild($comment)
foreach($pkg in $sortedPackages) {
    $newElement = $outXml.CreateElement("dependency")
    $newElement.SetAttribute("id", $pkg.Include)
    $newElement.SetAttribute("version", $pkg.Version)
    $newElement.SetAttribute("exclude", "Build,Analyzers")
    $_ = $groupElement.AppendChild($newElement)
}

# Create XmlWriterSettings
$settings = New-Object System.Xml.XmlWriterSettings
$settings.OmitXmlDeclaration = $true
$settings.Indent = $true
$settings.NewLineOnAttributes = $false

# Create a StreamWriter to write the XML to a file
$filePath = "${PSScriptRoot}\${OutputFile}"
$absolutePath = [System.IO.Path]::GetFullPath($filePath)
$streamWriter = [System.IO.StreamWriter]::new($absolutePath)
$xmlWriter = [System.Xml.XmlWriter]::Create($streamWriter, $settings)
$outXml.Save($xmlWriter)
$xmlWriter.Flush()
$streamWriter.Flush()
$xmlWriter.Close()
$streamWriter.Close()

# Output the file path
Write-Host "XML saved to: $absolutePath"
