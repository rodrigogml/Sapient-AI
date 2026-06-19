# next-task-id.ps1 - calcula o próximo ID hierárquico dentro de uma fase ou tarefa em um arquivo tasks.md.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts/next-task-id.ps1 FASE tasks.md
#   powershell -ExecutionPolicy Bypass -File scripts/next-task-id.ps1 TAREFA tasks.md
#
# Se o prefixo não existe, retorna {prefix}.1.

$ErrorActionPreference = "Stop"

function Show-Usage {
    [Console]::Error.WriteLine("Uso: next-task-id.ps1 PREFIX tasks.md")
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("Exemplos:")
    [Console]::Error.WriteLine("  next-task-id.ps1 1 tasks.md")
    [Console]::Error.WriteLine("  next-task-id.ps1 1.2 tasks.md")
    [Console]::Error.WriteLine("  next-task-id.ps1 3.5 tasks.md")
}

if ($args.Count -lt 2) {
    Show-Usage
    exit 2
}

$prefix = $args[0]
$file = $args[1]

if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    [Console]::Error.WriteLine("Arquivo não encontrado: {0}" -f $file)
    exit 1
}

$escapedPrefix = [regex]::Escape($prefix)
$pattern = "(^### |^- \[[ x~!]\] )$escapedPrefix\.[0-9]+"
$max = 0

foreach ($line in Get-Content -LiteralPath $file) {
    foreach ($match in [regex]::Matches($line, $pattern)) {
        $id = $match.Value -replace '^(### |- \[[ x~!]\] )', ''
        $number = $id -replace "^$escapedPrefix\.", ''
        $value = [int]$number

        if ($value -gt $max) {
            $max = $value
        }
    }
}

$next = $max + 1
Write-Output ("{0}.{1}" -f $prefix, $next)
