[CmdletBinding()]
param(
    [Parameter()]
    [string]$CodexHome,

    [Parameter()]
    [switch]$ListOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$scriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
$agentsSourceDirectory = Join-Path $repositoryRoot 'codex\agentes'
$notInstalledStatus = '[N' + [char]0x00C3 + 'O INSTALADO]'
$elevatedRestartRequested = $false
$requiredAgentFileNames = @(
    'AGENTS-DATABASE.md'
    'AGENTS-DELEGATOR.md'
    'AGENTS-DEVELOPMENT-CYCLE.md'
    'AGENTS-JAVA-CODING.md'
    'AGENTS-JAVA-SPRING-BOOT.md'
)

function Get-AbsolutePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)
    return [System.IO.Path]::GetFullPath(
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($expandedPath)
    )
}

function Get-CodexHomeDetection {
    if (-not [string]::IsNullOrWhiteSpace($CodexHome)) {
        return [PSCustomObject]@{
            Path   = Get-AbsolutePath -Path $CodexHome
            Source = 'parametro -CodexHome'
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        return [PSCustomObject]@{
            Path   = Get-AbsolutePath -Path $env:CODEX_HOME
            Source = 'variavel de ambiente CODEX_HOME'
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        return [PSCustomObject]@{
            Path   = Get-AbsolutePath -Path (Join-Path $env:USERPROFILE '.codex')
            Source = 'diretorio %USERPROFILE%\.codex'
        }
    }

    $userProfile = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    if (-not [string]::IsNullOrWhiteSpace($userProfile)) {
        return [PSCustomObject]@{
            Path   = Get-AbsolutePath -Path (Join-Path $userProfile '.codex')
            Source = 'perfil retornado pela API do Windows'
        }
    }

    throw 'Nao foi possivel detectar o diretorio do perfil do usuario.'
}

function Test-AgentRepository {
    if (-not (Test-Path -LiteralPath $agentsSourceDirectory -PathType Container)) {
        throw "Diretorio de agentes nao encontrado: '$agentsSourceDirectory'."
    }

    $missingAgentFileNames = @()
    foreach ($requiredAgentFileName in $requiredAgentFileNames) {
        $requiredAgentPath = Join-Path $agentsSourceDirectory $requiredAgentFileName
        if (-not (Test-Path -LiteralPath $requiredAgentPath -PathType Leaf)) {
            $missingAgentFileNames += $requiredAgentFileName
        }
    }

    if ($missingAgentFileNames.Count -gt 0) {
        $missingFiles = $missingAgentFileNames -join ', '
        throw "Repositorio invalido para instalacao. Arquivos de agentes obrigatorios ausentes em '$agentsSourceDirectory': $missingFiles."
    }
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsDeveloperModeEnabled {
    $developerModeRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    try {
        $developerModeConfiguration = Get-ItemProperty `
            -LiteralPath $developerModeRegistryPath `
            -Name 'AllowDevelopmentWithoutDevLicense' `
            -ErrorAction Stop
        return [int]$developerModeConfiguration.AllowDevelopmentWithoutDevLicense -eq 1
    }
    catch {
        return $false
    }
}

function Get-SymbolicLinkCapability {
    if (Test-IsAdministrator) {
        return [PSCustomObject]@{
            Available = $true
            Detail    = 'processo executado como administrador'
        }
    }

    if (Test-IsDeveloperModeEnabled) {
        return [PSCustomObject]@{
            Available = $true
            Detail    = 'Modo de Desenvolvedor habilitado'
        }
    }

    return [PSCustomObject]@{
        Available = $false
        Detail    = 'requer Modo de Desenvolvedor ou execucao como administrador'
    }
}

function Request-ElevatedRestart {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    $currentPowerShellPath = (Get-Process -Id $PID).Path
    $argumentList = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        ('"{0}"' -f $scriptPath)
        '-CodexHome'
        ('"{0}"' -f $TargetDirectory)
    )

    try {
        [void](Start-Process `
            -FilePath $currentPowerShellPath `
            -Verb RunAs `
            -ArgumentList $argumentList)
        Write-Host 'Uma nova janela elevada foi iniciada. Continue a instalacao nela.'
        $script:elevatedRestartRequested = $true
        return $true
    }
    catch {
        Write-Warning "Nao foi possivel iniciar o instalador como administrador: $($_.Exception.Message)"
        return $false
    }
}

function Confirm-SymbolicLinkAccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    $capability = Get-SymbolicLinkCapability
    if ($capability.Available) {
        return $true
    }

    Write-Warning "A criacao de symlinks $($capability.Detail)."
    Write-Host 'A instalacao por copia continua disponivel sem elevacao.'
    if (Confirm-Action -Message 'Deseja reiniciar o instalador como administrador?') {
        [void](Request-ElevatedRestart -TargetDirectory $TargetDirectory)
    }

    return $false
}

function Test-SamePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstPath,

        [Parameter(Mandatory = $true)]
        [string]$SecondPath
    )

    $firstFullPath = [System.IO.Path]::GetFullPath($FirstPath).TrimEnd('\', '/')
    $secondFullPath = [System.IO.Path]::GetFullPath($SecondPath).TrimEnd('\', '/')
    return [string]::Equals(
        $firstFullPath,
        $secondFullPath,
        [StringComparison]::OrdinalIgnoreCase
    )
}

function Get-SymbolicLinkTargetPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$Item
    )

    [string]$linkTarget = $Item.Target
    if ([string]::IsNullOrWhiteSpace($linkTarget)) {
        return $null
    }

    if (-not [System.IO.Path]::IsPathRooted($linkTarget)) {
        $linkTarget = Join-Path $Item.DirectoryName $linkTarget
    }

    return [System.IO.Path]::GetFullPath($linkTarget)
}

function Test-FilesEqual {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$SourceFile,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$TargetFile
    )

    if ($SourceFile.Length -ne $TargetFile.Length) {
        return $false
    }

    $sourceHash = (Get-FileHash -LiteralPath $SourceFile.FullName -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $TargetFile.FullName -Algorithm SHA256).Hash
    return [string]::Equals($sourceHash, $targetHash, [StringComparison]::OrdinalIgnoreCase)
}

function Get-AgentState {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$SourceFile,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    $targetPath = Join-Path $TargetDirectory $SourceFile.Name
    $targetItem = Get-Item -Force -LiteralPath $targetPath -ErrorAction SilentlyContinue

    if ($null -eq $targetItem) {
        return [PSCustomObject]@{
            SourceFile    = $SourceFile
            TargetPath    = $targetPath
            TargetItem    = $null
            State         = 'NotInstalled'
            DisplayStatus = $notInstalledStatus
            Detail        = $null
        }
    }

    if ($targetItem.PSIsContainer) {
        return [PSCustomObject]@{
            SourceFile    = $SourceFile
            TargetPath    = $targetPath
            TargetItem    = $targetItem
            State         = 'Unsupported'
            DisplayStatus = '[OBJETO NAO SUPORTADO]'
            Detail        = 'Existe um diretorio com o mesmo nome.'
        }
    }

    if ($targetItem.LinkType -eq 'SymbolicLink') {
        $linkTargetPath = Get-SymbolicLinkTargetPath -Item $targetItem
        if (($null -ne $linkTargetPath) -and
            (Test-SamePath -FirstPath $linkTargetPath -SecondPath $SourceFile.FullName)) {
            return [PSCustomObject]@{
                SourceFile    = $SourceFile
                TargetPath    = $targetPath
                TargetItem    = $targetItem
                State         = 'SymbolicLink'
                DisplayStatus = '[SYMLINK]'
                Detail        = $linkTargetPath
            }
        }

        return [PSCustomObject]@{
            SourceFile    = $SourceFile
            TargetPath    = $targetPath
            TargetItem    = $targetItem
            State         = 'SymbolicLinkDifferent'
            DisplayStatus = '[SYMLINK DIFERENTE]'
            Detail        = $linkTargetPath
        }
    }

    try {
        $filesEqual = Test-FilesEqual -SourceFile $SourceFile -TargetFile $targetItem
    }
    catch {
        return [PSCustomObject]@{
            SourceFile    = $SourceFile
            TargetPath    = $targetPath
            TargetItem    = $targetItem
            State         = 'FileDifferent'
            DisplayStatus = '[Arquivo DIFERENTE]'
            Detail        = 'Nao foi possivel calcular o hash do arquivo instalado.'
        }
    }

    if ($filesEqual) {
        return [PSCustomObject]@{
            SourceFile    = $SourceFile
            TargetPath    = $targetPath
            TargetItem    = $targetItem
            State         = 'FileEqual'
            DisplayStatus = '[Arquivo IGUAL]'
            Detail        = $null
        }
    }

    return [PSCustomObject]@{
        SourceFile    = $SourceFile
        TargetPath    = $targetPath
        TargetItem    = $targetItem
        State         = 'FileDifferent'
        DisplayStatus = '[Arquivo DIFERENTE]'
        Detail        = $null
    }
}

function Get-AgentStates {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    $sourceFiles = @(
        Get-ChildItem -LiteralPath $agentsSourceDirectory -File -Filter 'AGENTS*.md' |
            Sort-Object Name
    )

    if ($sourceFiles.Count -eq 0) {
        throw "Nenhum arquivo AGENTS*.md foi encontrado em '$agentsSourceDirectory'."
    }

    $states = @()
    foreach ($sourceFile in $sourceFiles) {
        $states += Get-AgentState -SourceFile $sourceFile -TargetDirectory $TargetDirectory
    }

    return $states
}

function Show-AgentStates {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$States,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    Write-Host ''
    Write-Host 'Instalador de agentes do Codex'
    Write-Host "Origem:  $agentsSourceDirectory"
    Write-Host "Destino: $TargetDirectory"
    Write-Host ''

    for ($index = 0; $index -lt $States.Count; $index++) {
        $state = $States[$index]
        Write-Host ('{0,2}. {1} {2}' -f ($index + 1), $state.DisplayStatus, $state.SourceFile.Name)
    }

    Write-Host ' 0. Sair'
    Write-Host ''
}

function Confirm-Action {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    [string]$answer = Read-Host "$Message [s/N]"
    $normalizedAnswer = $answer.Trim().ToLowerInvariant()
    return ($normalizedAnswer -eq 's') -or ($normalizedAnswer -eq 'sim')
}

function Wait-ForMenu {
    [void](Read-Host 'Pressione Enter para continuar')
}

function Initialize-TargetDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    if (-not (Test-Path -LiteralPath $TargetDirectory -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $TargetDirectory -Force)
    }
}

function Install-Agent {
    param(
        [Parameter(Mandatory = $true)]
        [object]$State,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory
    )

    Write-Host ''
    Write-Host '1. Copiar arquivo'
    Write-Host '2. Criar symlink'
    Write-Host '0. Voltar'
    [string]$method = Read-Host 'Escolha o metodo de instalacao'

    if ($method -eq '0') {
        return
    }

    if (($method -ne '1') -and ($method -ne '2')) {
        Write-Warning 'Metodo invalido.'
        Wait-ForMenu
        return
    }

    if (($method -eq '2') -and
        (-not (Confirm-SymbolicLinkAccess -TargetDirectory $TargetDirectory))) {
        return
    }

    $methodName = 'copiar o arquivo'
    if ($method -eq '2') {
        $methodName = 'criar o symlink'
    }

    if (-not (Confirm-Action -Message "Confirma instalar $($State.SourceFile.Name) por meio de ${methodName}?")) {
        return
    }

    Initialize-TargetDirectory -TargetDirectory $TargetDirectory

    try {
        if ($method -eq '1') {
            Copy-Item -LiteralPath $State.SourceFile.FullName -Destination $State.TargetPath
        }
        else {
            [void](New-Item -ItemType SymbolicLink -Path $State.TargetPath -Target $State.SourceFile.FullName)
        }

        Write-Host 'Instalacao concluida.'
    }
    catch {
        if ($method -eq '2') {
            Write-Warning "Nao foi possivel criar o symlink: $($_.Exception.Message)"
            Write-Warning 'Verifique o Modo de Desenvolvedor ou execute o instalador como administrador.'
        }
        else {
            Write-Warning "Nao foi possivel copiar o arquivo: $($_.Exception.Message)"
        }
    }

    Wait-ForMenu
}

function Uninstall-Agent {
    param(
        [Parameter(Mandatory = $true)]
        [object]$State
    )

    if ($State.State -eq 'FileDifferent') {
        Write-Warning "ATENCAO: '$($State.TargetPath)' e diferente do arquivo do repositorio e sera excluido permanentemente."
    }
    elseif ($State.State -eq 'SymbolicLinkDifferent') {
        Write-Warning "ATENCAO: o symlink aponta para outro local. Apenas o link sera removido; o destino atual nao sera alterado."
    }
    elseif ($State.State -eq 'SymbolicLink') {
        Write-Host 'Apenas o symlink sera removido; o arquivo do repositorio nao sera alterado.'
    }

    if (-not (Confirm-Action -Message "Confirma desinstalar $($State.SourceFile.Name)?")) {
        return
    }

    try {
        Remove-Item -Force -LiteralPath $State.TargetPath
        Write-Host 'Desinstalacao concluida.'
    }
    catch {
        Write-Warning "Nao foi possivel desinstalar o agente: $($_.Exception.Message)"
    }

    Wait-ForMenu
}

function Update-CopiedAgent {
    param(
        [Parameter(Mandatory = $true)]
        [object]$State
    )

    Write-Warning "ATENCAO: '$($State.TargetPath)' e diferente e sera sobrescrito pelo arquivo do repositorio."
    if (-not (Confirm-Action -Message "Confirma atualizar $($State.SourceFile.Name)?")) {
        return
    }

    try {
        Copy-Item -Force -LiteralPath $State.SourceFile.FullName -Destination $State.TargetPath
        Write-Host 'Atualizacao concluida.'
    }
    catch {
        Write-Warning "Nao foi possivel atualizar o arquivo: $($_.Exception.Message)"
    }

    Wait-ForMenu
}

function Update-SymbolicLink {
    param(
        [Parameter(Mandatory = $true)]
        [object]$State
    )

    $targetDirectory = Split-Path -Parent $State.TargetPath
    if (-not (Confirm-SymbolicLinkAccess -TargetDirectory $targetDirectory)) {
        return
    }

    Write-Warning 'ATENCAO: o symlink atual aponta para outro local e sera substituido.'
    if (-not (Confirm-Action -Message "Confirma atualizar $($State.SourceFile.Name)?")) {
        return
    }

    $temporaryLinkPath = Join-Path (
        Split-Path -Parent $State.TargetPath
    ) ('.' + $State.SourceFile.Name + '.' + [Guid]::NewGuid().ToString('N') + '.tmp')
    $backupLinkPath = Join-Path (
        Split-Path -Parent $State.TargetPath
    ) ('.' + $State.SourceFile.Name + '.' + [Guid]::NewGuid().ToString('N') + '.bak')

    try {
        [void](New-Item -ItemType SymbolicLink -Path $temporaryLinkPath -Target $State.SourceFile.FullName)
        Move-Item -LiteralPath $State.TargetPath -Destination $backupLinkPath
        Move-Item -LiteralPath $temporaryLinkPath -Destination $State.TargetPath

        try {
            Remove-Item -Force -LiteralPath $backupLinkPath
        }
        catch {
            Write-Warning "O symlink foi atualizado, mas o link anterior nao pode ser removido: '$backupLinkPath'."
        }

        Write-Host 'Atualizacao concluida.'
    }
    catch {
        $updateError = $_
        $temporaryLink = Get-Item -Force -LiteralPath $temporaryLinkPath -ErrorAction SilentlyContinue
        if ($null -ne $temporaryLink) {
            Remove-Item -Force -LiteralPath $temporaryLinkPath
        }

        $currentLink = Get-Item -Force -LiteralPath $State.TargetPath -ErrorAction SilentlyContinue
        $backupLink = Get-Item -Force -LiteralPath $backupLinkPath -ErrorAction SilentlyContinue
        if (($null -eq $currentLink) -and ($null -ne $backupLink)) {
            try {
                Move-Item -LiteralPath $backupLinkPath -Destination $State.TargetPath
            }
            catch {
                Write-Warning "Nao foi possivel restaurar o symlink anterior: '$backupLinkPath'."
            }
        }

        Write-Warning "Nao foi possivel atualizar o symlink: $($updateError.Exception.Message)"
        Write-Warning 'Verifique o Modo de Desenvolvedor ou execute o instalador como administrador.'
    }

    Wait-ForMenu
}

function Show-InstalledAgentActions {
    param(
        [Parameter(Mandatory = $true)]
        [object]$State
    )

    Write-Host ''
    Write-Host "$($State.DisplayStatus) $($State.SourceFile.Name)"
    if (-not [string]::IsNullOrWhiteSpace($State.Detail)) {
        Write-Host "Detalhe: $($State.Detail)"
    }

    if (($State.State -eq 'FileDifferent') -or ($State.State -eq 'SymbolicLinkDifferent')) {
        Write-Host '1. Atualizar'
        Write-Host '2. Desinstalar'
        Write-Host '0. Voltar'
        [string]$action = Read-Host 'Escolha uma acao'

        if ($action -eq '1') {
            if ($State.State -eq 'FileDifferent') {
                Update-CopiedAgent -State $State
            }
            else {
                Update-SymbolicLink -State $State
            }
        }
        elseif ($action -eq '2') {
            Uninstall-Agent -State $State
        }
        elseif ($action -ne '0') {
            Write-Warning 'Acao invalida.'
            Wait-ForMenu
        }

        return
    }

    Write-Host '1. Desinstalar'
    Write-Host '0. Voltar'
    [string]$installedAction = Read-Host 'Escolha uma acao'
    if ($installedAction -eq '1') {
        Uninstall-Agent -State $State
    }
    elseif ($installedAction -ne '0') {
        Write-Warning 'Acao invalida.'
        Wait-ForMenu
    }
}

$codexHomeDetection = Get-CodexHomeDetection
$codexHomePath = $codexHomeDetection.Path
$symbolicLinkCapability = Get-SymbolicLinkCapability
$symbolicLinkStatus = 'indisponivel'
if ($symbolicLinkCapability.Available) {
    $symbolicLinkStatus = 'disponivel'
}

Write-Host ''
Write-Host 'Contexto detectado'
Write-Host "Repositorio:      $repositoryRoot"
Write-Host "Diretorio Codex:  $codexHomePath"
Write-Host "Deteccao Codex:   $($codexHomeDetection.Source)"
Write-Host "Diretorio agents: $agentsSourceDirectory"
Write-Host "Symlink Windows:  $symbolicLinkStatus ($($symbolicLinkCapability.Detail))"

Test-AgentRepository
Write-Host "Validacao:        $($requiredAgentFileNames.Count) arquivos obrigatorios encontrados."

do {
    $agentStates = @(Get-AgentStates -TargetDirectory $codexHomePath)
    Show-AgentStates -States $agentStates -TargetDirectory $codexHomePath

    if ($ListOnly) {
        break
    }

    [string]$selection = Read-Host 'Escolha o numero de um agente'
    [int]$selectedNumber = -1
    if (-not [int]::TryParse($selection, [ref]$selectedNumber)) {
        Write-Warning 'Selecao invalida.'
        Wait-ForMenu
        continue
    }

    if ($selectedNumber -eq 0) {
        break
    }

    if (($selectedNumber -lt 1) -or ($selectedNumber -gt $agentStates.Count)) {
        Write-Warning 'Selecao fora da lista.'
        Wait-ForMenu
        continue
    }

    $selectedState = $agentStates[$selectedNumber - 1]
    if ($selectedState.State -eq 'NotInstalled') {
        Install-Agent -State $selectedState -TargetDirectory $codexHomePath
        if ($elevatedRestartRequested) {
            break
        }
    }
    elseif ($selectedState.State -eq 'Unsupported') {
        Write-Warning "$($selectedState.DisplayStatus) $($selectedState.Detail)"
        Write-Warning 'O instalador nao alterara esse objeto.'
        Wait-ForMenu
    }
    else {
        Show-InstalledAgentActions -State $selectedState
        if ($elevatedRestartRequested) {
            break
        }
    }
} while ($true)
