<#
.SYNOPSIS
    Sorts the library.db catalog by any combination of columns.

.EXAMPLE
    .\sort-books.cmd author year
    .\sort-books.cmd rating:desc popularity:desc -Limit 10
    .\sort-books.cmd condition title -OnShelf
    .\sort-books.cmd language author year:desc -Limit 0 -Csv sorted.csv

    Sort keys apply in the order given; add :desc to reverse one. Blank values
    (no year, no copy on the shelf) always sort last.
#>
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $By = @('title'),
    # How many rows to show; 0 shows all of them.
    [int] $Limit = 25,
    # Only books the library has a physical copy of.
    [switch] $OnShelf,
    # Write the sorted rows to this CSV file instead of the screen.
    [string] $Csv
)

$ErrorActionPreference = 'Stop'

# Sort key => SQL expression(s) on the book_catalog view.
$sortKeys = [ordered]@{
    title      = 'title COLLATE NOCASE'
    author     = 'author_last_name COLLATE NOCASE, primary_author COLLATE NOCASE'
    authorfull = 'primary_author COLLATE NOCASE'
    year       = 'publication_year'
    rating     = 'average_rating'
    popularity = 'ratings_count'
    language   = 'language_code'
    condition  = 'condition_rank'
    status     = 'status'
    acquired   = 'acquired_on'
    id         = 'book_id'
}

# From cmd.exe, "author,year" arrives as one string, so split on commas as well as spaces.
$keys = $By | ForEach-Object { $_ -split ',' } | Where-Object { $_ -ne '' }

$orderBy = foreach ($key in $keys) {
    $name, $direction = $key.ToLower() -split ':', 2
    if (-not $sortKeys.Contains($name)) {
        Write-Host "Unknown sort key '$name'. Valid keys: $($sortKeys.Keys -join ', ')" -ForegroundColor Red
        exit 1
    }
    if (-not $direction) { $direction = 'asc' }
    if ($direction -notin 'asc', 'desc') {
        Write-Host "Unknown direction '$direction' in '$key'. Use :asc or :desc." -ForegroundColor Red
        exit 1
    }
    foreach ($expr in $sortKeys[$name] -split ', ') {
        "$expr $($direction.ToUpper()) NULLS LAST"
    }
}
# Tiebreakers so equal rows always come out in the same order.
$orderBy = @($orderBy) + 'book_id', 'copy_id'

$sql = @"
SELECT book_id, title, all_authors AS authors, publication_year AS year,
       average_rating AS rating, ratings_count AS ratings, language_code AS lang,
       condition, status
FROM book_catalog
$(if ($OnShelf) { 'WHERE copy_id IS NOT NULL' })
ORDER BY $($orderBy -join ', ')
$(if ($Limit -gt 0) { "LIMIT $Limit" });
"@

$sqlite = (Get-Command sqlite3 -ErrorAction SilentlyContinue).Source
if (-not $sqlite) {
    $sqlite = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\SQLite.SQLite_Microsoft.Winget.Source_8wekyb3d8bbwe\sqlite3.exe"
}
$db = Join-Path $PSScriptRoot 'library.db'

if ($Csv) {
    # Combine keeps $Csv as-is when it is already a full path.
    $out = [IO.Path]::GetFullPath([IO.Path]::Combine((Get-Location).Path, $Csv)) -replace '\\', '/'
    & $sqlite -header -csv -cmd ".once '$out'" $db $sql
    Write-Host "Wrote sorted rows to $out"
} else {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    & $sqlite -header -cmd '.mode column --wrap 40' $db $sql
}
