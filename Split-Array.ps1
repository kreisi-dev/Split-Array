function Split-Array {
<#
.SYNOPSIS
    Splits an array into sub-arrays (chunks) using a configurable distribution strategy.

.DESCRIPTION
    Split-Array accepts an array — either as a direct argument or from the pipeline —
    and returns a list of sub-arrays.

    Two modes are available:

      -ChunkSize  Specifies the maximum number of elements per chunk.

      -MaxChunk   Specifies the desired number of chunks.

    For each mode, the -Distribution parameter controls how elements are arranged:

      Greedy      Fill each chunk as much as possible; the last chunk may be smaller.
                  This is the default for -ChunkSize.

      Even        Spread any remainder across chunks so sizes differ by at most one.
                  This is the default for -MaxChunk.

    Example — 1..10 with -MaxChunk 4:

      Greedy → (1,2,3), (4,5,6), (7,8,9), (10)    chunks: 3,3,3,1
      Even   → (1,2,3), (4,5,6), (7,8),   (9,10)   chunks: 3,3,2,2

    Example — 1..10 with -ChunkSize 3:

      Greedy → (1,2,3), (4,5,6), (7,8,9), (10)    chunks: 3,3,3,1
      Even   → (1,2,3), (4,5,6), (7,8),   (9,10)   chunks: 3,3,2,2

    Optionally, -Pad fills the last chunk to match the size of the first chunk.

.PARAMETER InputObject
    The array or individual elements to split.
    Accepts pipeline input.

.PARAMETER ChunkSize
    Maximum number of elements per chunk (ParameterSet: BySize).
    Must be greater than 0.
    If ChunkSize >= element count, a single chunk containing all elements is returned.
    Default distribution: Greedy.

.PARAMETER MaxChunk
    Desired number of output chunks (ParameterSet: ByMaxChunk).
    Must be greater than 0.
    If MaxChunk = 1, a single chunk is always returned.
    If element count <= MaxChunk, each element is returned in its own chunk.
    Default distribution: Even.

.PARAMETER Distribution
    Controls how elements are placed into chunks. Applies to both -ChunkSize and -MaxChunk.

      Greedy  Fill each chunk as much as possible; the last chunk absorbs any remainder.
              Default when using -ChunkSize.

              Note: when used with -MaxChunk, Greedy may produce fewer than MaxChunk chunks.
              Example: 1..6 with -MaxChunk 4 -Distribution Greedy yields 3 chunks of 2,
              because ceil(6/4)=2 divides 6 evenly into 3 full chunks.
              Use -Distribution Even to always get exactly MaxChunk chunks.

      Even    Spread the remainder one element at a time across the first chunks,
              so chunk sizes differ by at most one. Always produces exactly MaxChunk chunks
              (when Count > MaxChunk).
              Default when using -MaxChunk.

.PARAMETER Pad
    Pads the last chunk with the specified value until it matches the size of the first chunk.
    Accepts any value including $null (use -Pad $null to pad with null).
    Only applies when the last chunk is smaller than the first chunk.
    Has no effect when all chunks are already the same size.

.INPUTS
    System.Object
    Individual elements or arrays can be passed via the pipeline.

.OUTPUTS
    System.Object[][]
    An array of arrays. Each element of the outer array is one chunk.

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3

    Greedy (default): four chunks of 3, 3, 3, 1.
    Returns: (1,2,3), (4,5,6), (7,8,9), (10)

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3 -Distribution Even

    Even: four chunks of 3, 3, 2, 2 — no chunk is more than one element larger than another.
    Returns: (1,2,3), (4,5,6), (7,8), (9,10)

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3 -Pad $null

    Greedy with padding: last chunk is padded to match ChunkSize.
    Returns: (1,2,3), (4,5,6), (7,8,9), (10,$null,$null)

.EXAMPLE
    Split-Array -InputObject 1..7 -ChunkSize 4 -Pad 0

    Greedy with a custom pad value.
    Returns: (1,2,3,4), (5,6,7,0)

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 4

    Even (default): four chunks of 3, 3, 2, 2.
    Returns: (1,2,3), (4,5,6), (7,8), (9,10)

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 4 -Distribution Greedy

    Greedy: four chunks of 3, 3, 3, 1 — chunks filled first, remainder in the last.
    Returns: (1,2,3), (4,5,6), (7,8,9), (10)

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 4 -Distribution Greedy -Pad $null

    Greedy with padding: last chunk padded to match first chunk size.
    Returns: (1,2,3), (4,5,6), (7,8,9), (10,$null,$null)

.EXAMPLE
    1..10 | Split-Array -ChunkSize 4

    Pipeline variant with Greedy (default). Returns: (1,2,3,4), (5,6,7,8), (9,10).

.EXAMPLE
    $chunks = Split-Array -InputObject 1..7 -MaxChunk 3
    $chunks | ForEach-Object { $_ -join ',' }

    Processes each chunk individually. Output: "1,2,3" / "4,5" / "6,7"

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 4 -Verbose

    Verbose output showing how 10 elements are distributed across 4 chunks (Even mode):

      VERBOSE: Input count: 10
      VERBOSE: Mode: MaxChunk
      VERBOSE: MaxChunk: 4
      VERBOSE: Distribution: Even
      VERBOSE: Base size: 2
      VERBOSE: Remainder: 2
      VERBOSE: Chunks created: 4
      VERBOSE: Chunk sizes: 3, 3, 2, 2

.EXAMPLE
    Split-Array -InputObject 1..10 -MaxChunk 4 -Distribution Greedy -Verbose

    Verbose output for Greedy mode:

      VERBOSE: Input count: 10
      VERBOSE: Mode: MaxChunk
      VERBOSE: MaxChunk: 4
      VERBOSE: Distribution: Greedy
      VERBOSE: Base size: 3
      VERBOSE: Chunks created: 4
      VERBOSE: Chunk sizes: 3, 3, 3, 1

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3 -Distribution Even -Verbose

    Verbose output for ChunkSize + Even mode. Number of chunks is derived from ChunkSize,
    then elements are distributed evenly:

      VERBOSE: Input count: 10
      VERBOSE: Mode: ChunkSize
      VERBOSE: ChunkSize: 3
      VERBOSE: Distribution: Even
      VERBOSE: Number of chunks: 4
      VERBOSE: Base size: 2
      VERBOSE: Remainder: 2
      VERBOSE: Chunks created: 4
      VERBOSE: Chunk sizes: 3, 3, 2, 2

.EXAMPLE
    Split-Array -InputObject 1..10 -ChunkSize 3 -Pad $null -Verbose

    Verbose output when padding is applied:

      VERBOSE: Input count: 10
      VERBOSE: Mode: ChunkSize
      VERBOSE: ChunkSize: 3
      VERBOSE: Distribution: Greedy
      VERBOSE: Chunks created: 4
      VERBOSE: Chunk sizes: 3, 3, 3, 1
      VERBOSE: Pad value: ''
      VERBOSE: Last chunk padded from 1 to 3 elements

.NOTES
    The function always returns an array of arrays, even when the result contains
    only a single chunk. This ensures a consistent return type that can always
    be iterated without type-checking the output.

    Use -Verbose to trace the splitting logic: input count, active mode, distribution
    strategy, chunk distribution, and final chunk sizes are all reported.
#>
    [CmdletBinding(DefaultParameterSetName = 'BySize')]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [object]$InputObject,

        [Parameter(ParameterSetName = 'BySize')]
        [int]$ChunkSize,

        [Parameter(ParameterSetName = 'ByMaxChunk')]
        [int]$MaxChunk,

        [Parameter(ParameterSetName = 'BySize')]
        [Parameter(ParameterSetName = 'ByMaxChunk')]
        [ValidateSet('Greedy', 'Even')]
        [string]$Distribution,

        [Parameter(ParameterSetName = 'BySize')]
        [Parameter(ParameterSetName = 'ByMaxChunk')]
        [object]$Pad
    )

    begin {
        $buffer = New-Object System.Collections.Generic.List[object]
        $doPad  = $PSBoundParameters.ContainsKey('Pad')
    }

    process {
        if ($null -ne $InputObject) {
            if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
                foreach ($item in $InputObject) { $buffer.Add($item) }
            } else {
                $buffer.Add($InputObject)
            }
        }
    }

    end {

        $Array = $buffer.ToArray()
        $Count = $Array.Count

        Write-Verbose "Input count: $Count"

        if ($Count -eq 0) {
            Write-Verbose "Input empty — returning empty array."
            $chunks = @(,@())
            return ,$chunks
        }

        # Apply per-mode default when Distribution is not specified
        $effectiveDistribution = if ($Distribution) {
            $Distribution
        } elseif ($PSCmdlet.ParameterSetName -eq 'BySize') {
            'Greedy'
        } else {
            'Even'
        }

        #
        # MODE: ChunkSize
        #
        if ($PSCmdlet.ParameterSetName -eq 'BySize') {

            Write-Verbose "Mode: ChunkSize"
            Write-Verbose "ChunkSize: $ChunkSize"
            Write-Verbose "Distribution: $effectiveDistribution"

            if ($ChunkSize -le 0) { throw "ChunkSize must be greater than zero." }

            if ($ChunkSize -ge $Count) {
                Write-Verbose "ChunkSize >= count, returning a single chunk."
                Write-Verbose "Chunk sizes: $Count"
                $chunks = @(,$Array)
                return ,$chunks
            }

            $chunks = @()

            if ($effectiveDistribution -eq 'Greedy') {
                for ($i = 0; $i -lt $Count; $i += $ChunkSize) {
                    $end = [Math]::Min($i + $ChunkSize - 1, $Count - 1)
                    $chunks += ,$Array[$i..$end]
                }
            } else {
                # Even: determine number of chunks from ChunkSize, then distribute evenly
                $numChunks = [Math]::Ceiling($Count / $ChunkSize)
                $BaseSize  = [Math]::Floor($Count / $numChunks)
                $Remainder = $Count % $numChunks
                Write-Verbose "Number of chunks: $numChunks"
                Write-Verbose "Base size: $BaseSize"
                Write-Verbose "Remainder: $Remainder"
                $index = 0
                for ($i = 1; $i -le $numChunks; $i++) {
                    $size = $BaseSize
                    if ($Remainder -gt 0) { $size++; $Remainder-- }
                    $chunks += ,$Array[$index..($index + $size - 1)]
                    $index += $size
                }
            }

            Write-Verbose "Chunks created: $($chunks.Count)"
            Write-Verbose "Chunk sizes: $(($chunks | ForEach-Object { $_.Count }) -join ', ')"

            if ($doPad) { $chunks = Add-PadToLastChunk $chunks $Pad }

            return ,$chunks
        }

        #
        # MODE: MaxChunk
        #
        if ($PSCmdlet.ParameterSetName -eq 'ByMaxChunk') {

            Write-Verbose "Mode: MaxChunk"
            Write-Verbose "MaxChunk: $MaxChunk"
            Write-Verbose "Distribution: $effectiveDistribution"

            if ($MaxChunk -le 0) { throw "MaxChunk must be greater than zero." }

            if ($MaxChunk -eq 1) {
                Write-Verbose "MaxChunk = 1 → Returning a single chunk."
                Write-Verbose "Chunk sizes: $Count"
                $chunks = @(,$Array)
                return ,$chunks
            }

            if ($Count -le $MaxChunk) {
                Write-Verbose "Count <= MaxChunk → Returning $Count single-item chunks."
                $chunks = @()
                foreach ($item in $Array) { $chunks += ,@($item) }
                return ,$chunks
            }

            $chunks = @()

            if ($effectiveDistribution -eq 'Even') {
                $BaseSize  = [Math]::Floor($Count / $MaxChunk)
                $Remainder = $Count % $MaxChunk
                Write-Verbose "Base size: $BaseSize"
                Write-Verbose "Remainder: $Remainder"
                $index = 0
                for ($i = 1; $i -le $MaxChunk; $i++) {
                    $size = $BaseSize
                    if ($Remainder -gt 0) { $size++; $Remainder-- }
                    $chunks += ,$Array[$index..($index + $size - 1)]
                    $index += $size
                }
            } else {
                # Greedy: fill each chunk to ceil(Count/MaxChunk); last chunk absorbs remainder
                $BaseSize = [Math]::Ceiling($Count / $MaxChunk)
                Write-Verbose "Base size: $BaseSize"
                $index = 0
                while ($index -lt $Count) {
                    $end = [Math]::Min($index + $BaseSize - 1, $Count - 1)
                    $chunks += ,$Array[$index..$end]
                    $index += $BaseSize
                }
            }

            Write-Verbose "Chunks created: $($chunks.Count)"
            Write-Verbose "Chunk sizes: $(($chunks | ForEach-Object { $_.Count }) -join ', ')"

            if ($doPad) { $chunks = Add-PadToLastChunk $chunks $Pad }

            return ,$chunks
        }
    }
}

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
