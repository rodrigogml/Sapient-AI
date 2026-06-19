# validate-tasks-template.ps1 - gate determinístico de fidelidade ao template da skill create-tasks.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts/validate-tasks-template.ps1 FILE [--phase-prefix PREFIX] [--config CONFIG_JSON]
#
# Saída:
#   FINDING|<severity>|<code>|<mensagem>
#   RESULT|<file>|critical=<N>|warning=<M>
#
# Exit: 0 conformante; 1 drift; 2 uso incorreto ou arquivo inexistente.

$ErrorActionPreference = "Stop"

function Show-Usage {
    [Console]::Error.WriteLine("Uso: validate-tasks-template.ps1 FILE [--phase-prefix PREFIX] [--config CONFIG_JSON]")
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("Valida se FILE, um tasks.md, está conforme ao template canônico da skill.")
    [Console]::Error.WriteLine("Emite linhas FINDING|severity|code|msg e um RESULT final.")
    [Console]::Error.WriteLine("Exit: 0 conformante; 1 drift; 2 uso/arquivo.")
}

$file = ""
$prefixOverride = ""
$config = ""
$index = 0

while ($index -lt $args.Count) {
    $argument = $args[$index]

    switch -Regex ($argument) {
        '^--phase-prefix$' {
            if ($index + 1 -ge $args.Count) {
                Show-Usage
                exit 2
            }

            $prefixOverride = $args[$index + 1]
            $index += 2
            continue
        }
        '^--phase-prefix=.*' {
            $prefixOverride = $argument.Substring("--phase-prefix=".Length)
            $index += 1
            continue
        }
        '^--config$' {
            if ($index + 1 -ge $args.Count) {
                Show-Usage
                exit 2
            }

            $config = $args[$index + 1]
            $index += 2
            continue
        }
        '^--config=.*' {
            $config = $argument.Substring("--config=".Length)
            $index += 1
            continue
        }
        '^(-h|--help)$' {
            Show-Usage
            exit 2
        }
        '^--.*' {
            [Console]::Error.WriteLine("Opção desconhecida: {0}" -f $argument)
            Show-Usage
            exit 2
        }
        default {
            if ([string]::IsNullOrEmpty($file)) {
                $file = $argument
                $index += 1
                continue
            }

            [Console]::Error.WriteLine("Argumento extra: {0}" -f $argument)
            Show-Usage
            exit 2
        }
    }
}

if ([string]::IsNullOrEmpty($file)) {
    Show-Usage
    exit 2
}

if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    [Console]::Error.WriteLine("Arquivo não encontrado: {0}" -f $file)
    exit 2
}

$prefix = "FASE"
if (-not [string]::IsNullOrEmpty($prefixOverride)) {
    $prefix = $prefixOverride
} elseif (-not [string]::IsNullOrEmpty($config) -and (Test-Path -LiteralPath $config -PathType Leaf)) {
    try {
        $json = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
        if ($null -ne $json.phase_prefix -and -not [string]::IsNullOrEmpty([string]$json.phase_prefix)) {
            $prefix = [string]$json.phase_prefix
        }
    } catch {
        # Mantém o default para preservar o comportamento tolerante do script sh.
    }
}

$escapedPrefix = [regex]::Escape($prefix)
$critical = 0
$warning = 0
$lines = Get-Content -LiteralPath $file

function Emit-Finding {
    param(
        [string]$Severity,
        [string]$Code,
        [string]$Message
    )

    Write-Output ("FINDING|{0}|{1}|{2}" -f $Severity, $Code, $Message)

    if ($Severity -eq "critical") {
        $script:critical += 1
    } else {
        $script:warning += 1
    }
}

function Count-Matches {
    param([string]$Pattern)

    $count = 0
    foreach ($line in $lines) {
        if ($line -match $Pattern) {
            $count += 1
        }
    }

    return $count
}

function Has-Match {
    param([string]$Pattern)

    foreach ($line in $lines) {
        if ($line -imatch $Pattern) {
            return $true
        }
    }

    return $false
}

if ((Count-Matches "^##\s+$escapedPrefix\s") -eq 0) {
    Emit-Finding "critical" "no-phase" ("Nenhum heading de fase '## {0} <N>' encontrado" -f $prefix)
}

if ((Count-Matches '^- \[[ x~!]\]') -eq 0) {
    Emit-Finding "critical" "no-checkbox" "Nenhuma subtarefa em formato checkbox '- [ ]' encontrada"
}

if ((Count-Matches '^###\s+.*`\[[A-Z]+\]`') -eq 0) {
    Emit-Finding "critical" "no-criticality" "Nenhuma tarefa com tag de criticidade '`[C|A|M]`' encontrada"
}

if (-not (Has-Match 'Legenda de status')) {
    Emit-Finding "warning" "no-status-legend" "Bloco 'Legenda de status' ausente"
}

if (-not (Has-Match 'Legenda de criticidade')) {
    Emit-Finding "warning" "no-crit-legend" "Bloco 'Legenda de criticidade' ausente"
}

if (-not (Has-Match 'Matriz de Depend')) {
    Emit-Finding "warning" "no-dependency-matrix" "Seção 'Matriz de Dependências' ausente"
}

if (-not (Has-Match 'Resumo Quantitativo')) {
    Emit-Finding "warning" "no-summary" "Seção 'Resumo Quantitativo' ausente"
}

if (-not (Has-Match 'Escopo Coberto')) {
    Emit-Finding "warning" "no-scope-covered" "Seção 'Escopo Coberto' ausente"
}

if (-not (Has-Match 'Escopo Exclu')) {
    Emit-Finding "warning" "no-scope-excluded" "Seção 'Escopo Excluído' ausente"
}

Write-Output ("RESULT|{0}|critical={1}|warning={2}" -f $file, $critical, $warning)

if ($critical -gt 0 -or $warning -gt 0) {
    exit 1
}

exit 0
