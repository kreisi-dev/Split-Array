BeforeAll {
    . "$PSScriptRoot/Split-Array.ps1"
}

Describe 'Split-Array' {

    Context 'BySize — basic splitting' {

        It 'splits 10 elements into chunks of 3' {
            $result = Split-Array -InputObject (1..10) -ChunkSize 3
            $result.Count          | Should -Be 4
            $result[0]             | Should -Be @(1, 2, 3)
            $result[3]             | Should -Be @(10)
        }

        It 'splits evenly without remainder' {
            $result = Split-Array -InputObject (1..9) -ChunkSize 3
            $result.Count | Should -Be 3
            $result | ForEach-Object { $_.Count | Should -Be 3 }
        }

        It 'returns a single chunk when ChunkSize >= Count' {
            $result = Split-Array -InputObject (1..3) -ChunkSize 10
            $result.Count    | Should -Be 1
            $result[0].Count | Should -Be 3
        }

        It 'returns single-element chunks when ChunkSize = 1' {
            $result = Split-Array -InputObject (1..4) -ChunkSize 1
            $result.Count | Should -Be 4
            $result | ForEach-Object { $_.Count | Should -Be 1 }
        }

        It 'throws when ChunkSize is 0' {
            { Split-Array -InputObject (1..5) -ChunkSize 0 } | Should -Throw
        }

        It 'throws when ChunkSize is negative' {
            { Split-Array -InputObject (1..5) -ChunkSize -1 } | Should -Throw
        }
    }

    Context 'BySize — pipeline input' {

        It 'accepts pipeline input' {
            $result = 1..6 | Split-Array -ChunkSize 2
            $result.Count | Should -Be 3
        }
    }

    Context 'ByMaxChunk — basic splitting' {

        It 'splits 10 elements into 3 chunks evenly' {
            $result = Split-Array -InputObject (1..10) -MaxChunk 3
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 4
            $result[1].Count | Should -Be 3
            $result[2].Count | Should -Be 3
        }

        It 'splits 7 elements into 3 chunks' {
            $result = Split-Array -InputObject (1..7) -MaxChunk 3
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 3
            $result[1].Count | Should -Be 2
            $result[2].Count | Should -Be 2
        }

        It 'returns a single chunk when MaxChunk = 1' {
            $result = Split-Array -InputObject (1..5) -MaxChunk 1
            $result.Count    | Should -Be 1
            $result[0].Count | Should -Be 5
        }

        It 'returns single-element chunks when Count <= MaxChunk' {
            $result = Split-Array -InputObject (1..3) -MaxChunk 10
            $result.Count | Should -Be 3
            $result | ForEach-Object { $_.Count | Should -Be 1 }
        }

        It 'throws when MaxChunk is 0' {
            { Split-Array -InputObject (1..5) -MaxChunk 0 } | Should -Throw
        }

        It 'throws when MaxChunk is negative' {
            { Split-Array -InputObject (1..5) -MaxChunk -1 } | Should -Throw
        }
    }

    Context 'Edge cases' {

        It 'returns one empty chunk for empty input' {
            $result = Split-Array -InputObject @() -ChunkSize 3
            $result.Count    | Should -Be 1
            $result[0].Count | Should -Be 0
        }

        It 'handles string elements without splitting them into characters' {
            $result = Split-Array -InputObject @('foo', 'bar', 'baz') -ChunkSize 2
            $result.Count    | Should -Be 2
            $result[0].Count | Should -Be 2
            $result[0][0]    | Should -Be 'foo'
        }

        It 'handles a single element' {
            $result = Split-Array -InputObject @(42) -ChunkSize 5
            $result.Count    | Should -Be 1
            $result[0][0]    | Should -Be 42
        }
    }
}
