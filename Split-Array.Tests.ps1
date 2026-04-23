BeforeAll {
    . "$PSScriptRoot/Split-Array.ps1"
}

Describe 'Split-Array' {

    Context 'BySize — Greedy (default)' {

        It 'splits 10 elements into chunks of 3' {
            $result = Split-Array -InputObject (1..10) -ChunkSize 3
            $result.Count | Should -Be 4
            $result[0]    | Should -Be @(1, 2, 3)
            $result[3]    | Should -Be @(10)
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

    Context 'BySize — Greedy (explicit)' {

        It 'produces same result as default' {
            $default  = Split-Array -InputObject (1..10) -ChunkSize 3
            $explicit = Split-Array -InputObject (1..10) -ChunkSize 3 -Distribution Greedy
            $explicit.Count | Should -Be $default.Count
            for ($i = 0; $i -lt $explicit.Count; $i++) {
                $explicit[$i] | Should -Be $default[$i]
            }
        }
    }

    Context 'BySize — Even' {

        It 'distributes 10 elements with ChunkSize 3 into balanced chunks (3,3,2,2)' {
            $result = Split-Array -InputObject (1..10) -ChunkSize 3 -Distribution Even
            $result.Count    | Should -Be 4
            $result[0]       | Should -Be @(1, 2, 3)
            $result[1]       | Should -Be @(4, 5, 6)
            $result[2]       | Should -Be @(7, 8)
            $result[3]       | Should -Be @(9, 10)
        }

        It 'produces same result as Greedy when count divides evenly' {
            $greedy = Split-Array -InputObject (1..9) -ChunkSize 3
            $even   = Split-Array -InputObject (1..9) -ChunkSize 3 -Distribution Even
            $even.Count | Should -Be $greedy.Count
            for ($i = 0; $i -lt $even.Count; $i++) {
                $even[$i] | Should -Be $greedy[$i]
            }
        }

        It 'distributes 7 elements with ChunkSize 3 into balanced chunks (3,2,2)' {
            $result = Split-Array -InputObject (1..7) -ChunkSize 3 -Distribution Even
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 3
            $result[1].Count | Should -Be 2
            $result[2].Count | Should -Be 2
        }
    }

    Context 'BySize — pipeline input' {

        It 'accepts pipeline input' {
            $result = 1..6 | Split-Array -ChunkSize 2
            $result.Count | Should -Be 3
        }
    }

    Context 'ByMaxChunk — Even (default)' {

        It 'splits 10 elements into 3 chunks evenly' {
            $result = Split-Array -InputObject (1..10) -MaxChunk 3
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 4
            $result[1].Count | Should -Be 3
            $result[2].Count | Should -Be 3
        }

        It 'splits 10 elements into 4 chunks evenly (3,3,2,2)' {
            $result = Split-Array -InputObject (1..10) -MaxChunk 4
            $result.Count    | Should -Be 4
            $result[0]       | Should -Be @(1, 2, 3)
            $result[1]       | Should -Be @(4, 5, 6)
            $result[2]       | Should -Be @(7, 8)
            $result[3]       | Should -Be @(9, 10)
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

    Context 'ByMaxChunk — Even (explicit)' {

        It 'produces same result as default' {
            $default  = Split-Array -InputObject (1..10) -MaxChunk 4
            $explicit = Split-Array -InputObject (1..10) -MaxChunk 4 -Distribution Even
            $explicit.Count | Should -Be $default.Count
            for ($i = 0; $i -lt $explicit.Count; $i++) {
                $explicit[$i] | Should -Be $default[$i]
            }
        }
    }

    Context 'ByMaxChunk — Greedy' {

        It 'distributes 10 elements into 4 chunks greedily (3,3,3,1)' {
            $result = Split-Array -InputObject (1..10) -MaxChunk 4 -Distribution Greedy
            $result.Count    | Should -Be 4
            $result[0]       | Should -Be @(1, 2, 3)
            $result[1]       | Should -Be @(4, 5, 6)
            $result[2]       | Should -Be @(7, 8, 9)
            $result[3]       | Should -Be @(10)
        }

        It 'distributes 10 elements into 3 chunks greedily (4,4,2)' {
            $result = Split-Array -InputObject (1..10) -MaxChunk 3 -Distribution Greedy
            $result.Count | Should -Be 3
            $result[0]    | Should -Be @(1, 2, 3, 4)
            $result[1]    | Should -Be @(5, 6, 7, 8)
            $result[2]    | Should -Be @(9, 10)
        }

        It 'produces fewer than MaxChunk chunks when count divides evenly into base size' {
            # 6 elements, MaxChunk=4: ceil(6/4)=2, so 3 full chunks of 2 — not 4
            $result = Split-Array -InputObject (1..6) -MaxChunk 4 -Distribution Greedy
            $result.Count | Should -Be 3
            $result[0]    | Should -Be @(1, 2)
            $result[1]    | Should -Be @(3, 4)
            $result[2]    | Should -Be @(5, 6)
        }

        It 'distributes 7 elements into 3 chunks greedily (3,3,1)' {
            $result = Split-Array -InputObject (1..7) -MaxChunk 3 -Distribution Greedy
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 3
            $result[1].Count | Should -Be 3
            $result[2].Count | Should -Be 1
        }

        It 'produces same result as Even when count divides evenly' {
            $greedy = Split-Array -InputObject (1..9) -MaxChunk 3 -Distribution Greedy
            $even   = Split-Array -InputObject (1..9) -MaxChunk 3 -Distribution Even
            $greedy.Count | Should -Be $even.Count
            for ($i = 0; $i -lt $greedy.Count; $i++) {
                $greedy[$i] | Should -Be $even[$i]
            }
        }
    }

    Context 'BySize — pipeline input with Distribution' {

        It 'accepts pipeline input with Distribution Even' {
            $result = 1..7 | Split-Array -ChunkSize 3 -Distribution Even
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 3
            $result[1].Count | Should -Be 2
            $result[2].Count | Should -Be 2
        }

        It 'accepts pipeline input with Distribution Greedy' {
            $result = 1..7 | Split-Array -ChunkSize 3 -Distribution Greedy
            $result.Count    | Should -Be 3
            $result[0].Count | Should -Be 3
            $result[1].Count | Should -Be 3
            $result[2].Count | Should -Be 1
        }
    }

    Context 'Edge cases' {

        It 'returns one empty chunk for empty input with ChunkSize' {
            $result = Split-Array -InputObject @() -ChunkSize 3
            $result.Count    | Should -Be 1
            $result[0].Count | Should -Be 0
        }

        It 'returns one empty chunk for empty input with MaxChunk' {
            $result = Split-Array -InputObject @() -MaxChunk 3
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
