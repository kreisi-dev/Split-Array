# Dot-source every function file under Public/ and Private/, then export only the
# public functions. New public functions must also be listed in FunctionsToExport
# in the module manifest (SplitArray.psd1) to be visible to consumers.

$Public  = @(Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1"  -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)

foreach ($file in @($Public + $Private)) {
    try {
        . $file.FullName
    } catch {
        throw "Failed to import function $($file.FullName): $_"
    }
}

if ($Public.Count -gt 0) {
    Export-ModuleMember -Function $Public.BaseName
}
