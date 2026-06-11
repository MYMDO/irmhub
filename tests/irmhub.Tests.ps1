BeforeAll {
    $irmhubPath = Join-Path $PSScriptRoot '..' 'irmhub.ps1' -Resolve
    . $irmhubPath
}

Describe 'Search-Tools' {
    It 'finds tools by name' {
        $results = Search-Tools -Keyword 'scoop'
        $results.Count | Should -BeGreaterThan 0
        $results[0].Name | Should -BeLike '*scoop*'
    }

    It 'finds tools by keyword in description' {
        $results = Search-Tools -Keyword 'runtime'
        $results.Count | Should -BeGreaterThan 0
    }

    It 'is case-insensitive' {
        $lower = Search-Tools -Keyword 'python'
        $upper = Search-Tools -Keyword 'PYTHON'
        $lower.Count | Should -Be $upper.Count
    }

    It 'returns all tools for empty keyword' {
        $results = Search-Tools -Keyword ''
        $results.Count | Should -Be $CATALOG.Count
    }

    It 'returns empty for unmatched keyword' {
        $results = Search-Tools -Keyword 'zzzznotexist'
        $results.Count | Should -Be 0
    }
}

Describe 'Get-ToolById' {
    It 'returns correct tool for valid ID' {
        $tool = Get-ToolById -Id 1
        $tool.Name | Should -Be 'Scoop'
    }

    It 'returns null for non-existent ID' {
        $tool = Get-ToolById -Id 999
        $tool | Should -BeNullOrEmpty
    }
}

Describe 'Get-ToolsByCategory' {
    It 'filters by category (case-insensitive)' {
        $lower = Get-ToolsByCategory -Category 'javascript'
        $mixed = Get-ToolsByCategory -Category 'JavaScript'
        $lower.Count | Should -Be $mixed.Count
        $lower.Count | Should -BeGreaterThan 0
    }

    It 'returns all tools for All category' {
        $results = Get-ToolsByCategory -Category 'All'
        $results.Count | Should -Be $CATALOG.Count
    }

    It 'returns empty for non-existent category' {
        $results = Get-ToolsByCategory -Category 'Nonexistent'
        $results.Count | Should -Be 0
    }
}

Describe 'Test-AdministratorRights' {
    It 'runs without error (cross-platform safe)' {
        { $null = Test-AdministratorRights } | Should -Not -Throw
    }
}

Describe 'Get-ConsoleWidth' {
    It 'returns a positive integer capped at 100' {
        $width = Get-ConsoleWidth
        $width | Should -BeGreaterThan 0
        $width | Should -BeLessOrEqual 100
    }
}

Describe 'Format-Color' {
    It 'returns string with ANSI codes when colors enabled' {
        $result = Format-Color -Text 'test' -ColorCode 'Red'
        $result | Should -Not -BeNullOrEmpty
    }
}
