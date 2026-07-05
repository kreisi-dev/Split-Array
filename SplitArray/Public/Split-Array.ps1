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

    $null handling: $null values sent through the pipeline are silently ignored
    and do not appear in the output. Arrays containing $null passed via
    -InputObject do preserve $null elements, because the IEnumerable iteration
    inside the function adds them directly to the buffer.

    Nested arrays: non-string IEnumerable elements (e.g. inner arrays) received
    via the pipeline are flattened one level, because PowerShell unrolls the
    outer array before invoking the process block, and the function then iterates
    each inner array in turn. When passing nested arrays via -InputObject, the
    outer array is iterated once and inner arrays are kept as atomic elements.

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

.EXAMPLE
    $null | Split-Array -ChunkSize 2

    $null sent via the pipeline is silently ignored; the function returns one empty chunk.
    To preserve $null as an element, pass the array via -InputObject instead:
    Split-Array -InputObject @(1, $null, 2) -ChunkSize 2
    Returns: (1,$null), (2)

.EXAMPLE
    @(1,2), @(3,4) | Split-Array -ChunkSize 1

    PowerShell unrolls the outer array in the pipeline; the function then iterates
    each inner array, flattening them. Returns four single-element chunks: (1),(2),(3),(4).
    To treat each inner array as one element, pass via -InputObject:
    Split-Array -InputObject @(@(1,2), @(3,4)) -ChunkSize 1
    Returns: ((1,2)), ((3,4))

.NOTES
    The function always returns an array of arrays, even when the result contains
    only a single chunk. This ensures a consistent return type that can always
    be iterated without type-checking the output.

    Use -Verbose to trace the splitting logic: input count, active mode, distribution
    strategy, chunk distribution, and final chunk sizes are all reported.
#>
    [CmdletBinding(DefaultParameterSetName = 'BySize')]
    [OutputType([object[]])]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [object]$InputObject,

        [Parameter(ParameterSetName = 'BySize', Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$ChunkSize,

        [Parameter(ParameterSetName = 'ByMaxChunk', Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
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
        $buffer = [System.Collections.Generic.List[object]]::new()
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

        $items = $buffer.ToArray()
        $count = $items.Count

        Write-Verbose "Input count: $count"

        if ($count -eq 0) {
            Write-Verbose "Input empty — returning empty array."
            return ,@(,@())
        }

        $bySize = $PSCmdlet.ParameterSetName -eq 'BySize'

        # Apply per-mode default when Distribution is not specified
        $effectiveDistribution = if ($Distribution) {
            $Distribution
        } elseif ($bySize) {
            'Greedy'
        } else {
            'Even'
        }

        if ($bySize) {
            Write-Verbose "Mode: ChunkSize"
            Write-Verbose "ChunkSize: $ChunkSize"
        } else {
            Write-Verbose "Mode: MaxChunk"
            Write-Verbose "MaxChunk: $MaxChunk"
        }
        Write-Verbose "Distribution: $effectiveDistribution"

        # Trivial cases that need no distribution logic
        if ($bySize -and $ChunkSize -ge $count) {
            Write-Verbose "ChunkSize >= count, returning a single chunk."
            Write-Verbose "Chunk sizes: $count"
            return ,@(,$items)
        }

        if (-not $bySize) {
            if ($MaxChunk -eq 1) {
                Write-Verbose "MaxChunk = 1 → Returning a single chunk."
                Write-Verbose "Chunk sizes: $count"
                return ,@(,$items)
            }

            if ($count -le $MaxChunk) {
                Write-Verbose "Count <= MaxChunk → Returning $count single-item chunks."
                $singles = [System.Collections.Generic.List[object]]::new()
                foreach ($item in $items) { $singles.Add(@($item)) }
                return ,$singles.ToArray()
            }
        }

        $chunkList = [System.Collections.Generic.List[object]]::new()

        if ($effectiveDistribution -eq 'Greedy') {
            # Chunk width: ChunkSize directly, or ceil(count / MaxChunk)
            $stride = if ($bySize) {
                $ChunkSize
            } else {
                $s = [int][Math]::Ceiling($count / $MaxChunk)
                Write-Verbose "Base size: $s"
                $s
            }
            for ($index = 0; $index -lt $count; $index += $stride) {
                $last = [Math]::Min($index + $stride - 1, $count - 1)
                $chunkList.Add($items[$index..$last])
            }
        } else {
            # Even: number of chunks from ChunkSize, or MaxChunk directly;
            # spread the remainder one element at a time across the first chunks
            $numChunks = if ($bySize) {
                $n = [int][Math]::Ceiling($count / $ChunkSize)
                Write-Verbose "Number of chunks: $n"
                $n
            } else {
                $MaxChunk
            }
            $baseSize  = [int][Math]::Floor($count / $numChunks)
            $remainder = $count % $numChunks
            Write-Verbose "Base size: $baseSize"
            Write-Verbose "Remainder: $remainder"
            $index = 0
            for ($i = 1; $i -le $numChunks; $i++) {
                $size = $baseSize
                if ($remainder -gt 0) { $size++; $remainder-- }
                $chunkList.Add($items[$index..($index + $size - 1)])
                $index += $size
            }
        }

        $chunks = $chunkList.ToArray()

        Write-Verbose "Chunks created: $($chunks.Count)"
        Write-Verbose "Chunk sizes: $(($chunks | ForEach-Object { $_.Count }) -join ', ')"

        if ($doPad) { $chunks = Add-PadToLastChunk -Chunks $chunks -PadValue $Pad }

        return ,$chunks
    }
}
