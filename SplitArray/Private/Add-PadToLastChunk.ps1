function Add-PadToLastChunk {
    param([object[]]$Chunks, [object]$PadValue)

    $targetSize = $Chunks[0].Count
    $last       = $Chunks[$Chunks.Count - 1]

    Write-Verbose "Pad value: '$PadValue'"

    if ($last.Count -ge $targetSize) {
        Write-Verbose "Last chunk already full — no padding needed."
        return $Chunks
    }

    $padded = New-Object object[] $targetSize
    [Array]::Copy($last, $padded, $last.Count)
    for ($j = $last.Count; $j -lt $targetSize; $j++) { $padded[$j] = $PadValue }

    Write-Verbose "Last chunk padded from $($last.Count) to $targetSize elements."
    $Chunks[$Chunks.Count - 1] = $padded
    return $Chunks
}
