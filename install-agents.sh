#!/usr/bin/env bash

set -u
set -o pipefail

CODEX_HOME_ARGUMENT=""
LIST_ONLY=false

show_usage() {
    cat <<'EOF'
Uso:
  bash install-agents.sh [--codex-home DIRETORIO] [--list-only]

Opções:
  --codex-home DIRETORIO  Define explicitamente o diretório do Codex.
  --list-only             Lista os agentes sem abrir o menu interativo.
  -h, --help              Exibe esta ajuda.
EOF
}

while (($# > 0)); do
    case "$1" in
        --codex-home)
            if (($# < 2)); then
                printf 'Erro: --codex-home exige um diretório.\n' >&2
                exit 1
            fi
            CODEX_HOME_ARGUMENT="$2"
            shift 2
            ;;
        --codex-home=*)
            CODEX_HOME_ARGUMENT="${1#*=}"
            shift
            ;;
        --list-only)
            LIST_ONLY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            printf 'Erro: argumento desconhecido: %s\n' "$1" >&2
            show_usage >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPOSITORY_ROOT="$SCRIPT_DIRECTORY"
AGENTS_SOURCE_DIRECTORY="$REPOSITORY_ROOT/codex/agentes"
CODEX_HOME_PATH=""
CODEX_HOME_SOURCE=""
CURRENT_STATE=""
CURRENT_STATUS=""
CURRENT_DETAIL=""
CURRENT_TARGET_PATH=""

REQUIRED_AGENT_FILE_NAMES=(
    "AGENTS-DATABASE.md"
    "AGENTS-DELEGATOR.md"
    "AGENTS-DEVELOPMENT-CYCLE.md"
    "AGENTS-JAVA-CODING.md"
    "AGENTS-JAVA-SPRING-BOOT.md"
)

AGENT_NAMES=()
AGENT_STATES=()
AGENT_STATUSES=()
AGENT_DETAILS=()
AGENT_TARGET_PATHS=()

validate_dependencies() {
    local command_name
    local missing_commands=()

    for command_name in basename cp dirname ln mkdir mv readlink rm sha256sum sort stat; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            missing_commands+=("$command_name")
        fi
    done

    if ((${#missing_commands[@]} > 0)); then
        printf 'Erro: comandos obrigatórios não encontrados: %s\n' \
            "${missing_commands[*]}" >&2
        exit 1
    fi

    if ((BASH_VERSINFO[0] < 4)); then
        printf 'Erro: este instalador exige Bash 4 ou superior.\n' >&2
        exit 1
    fi
}

absolute_path() {
    local path="$1"

    if [[ "$path" == "~" ]]; then
        path="${HOME:-$path}"
    elif [[ "$path" == "~/"* ]] && [[ -n "${HOME:-}" ]]; then
        path="$HOME/${path#~/}"
    fi

    readlink -m -- "$path"
}

detect_codex_home() {
    local detected_path=""
    local profile_directory=""

    if [[ -n "$CODEX_HOME_ARGUMENT" ]]; then
        detected_path="$CODEX_HOME_ARGUMENT"
        CODEX_HOME_SOURCE="parâmetro --codex-home"
    elif [[ -n "${CODEX_HOME:-}" ]]; then
        detected_path="$CODEX_HOME"
        CODEX_HOME_SOURCE="variável de ambiente CODEX_HOME"
    elif [[ -n "${HOME:-}" ]]; then
        detected_path="$HOME/.codex"
        CODEX_HOME_SOURCE='diretório $HOME/.codex'
    else
        profile_directory="$(cd ~ 2>/dev/null && pwd -P)"
        if [[ -z "$profile_directory" ]]; then
            printf 'Erro: não foi possível detectar o diretório do usuário.\n' >&2
            exit 1
        fi
        detected_path="$profile_directory/.codex"
        CODEX_HOME_SOURCE="perfil retornado pelo sistema"
    fi

    CODEX_HOME_PATH="$(absolute_path "$detected_path")"
}

validate_agent_repository() {
    local required_agent_name
    local required_agent_path
    local missing_agent_names=()

    if [[ ! -d "$AGENTS_SOURCE_DIRECTORY" ]]; then
        printf "Erro: diretório de agentes não encontrado: '%s'.\n" \
            "$AGENTS_SOURCE_DIRECTORY" >&2
        exit 1
    fi

    for required_agent_name in "${REQUIRED_AGENT_FILE_NAMES[@]}"; do
        required_agent_path="$AGENTS_SOURCE_DIRECTORY/$required_agent_name"
        if [[ ! -f "$required_agent_path" ]]; then
            missing_agent_names+=("$required_agent_name")
        fi
    done

    if ((${#missing_agent_names[@]} > 0)); then
        printf "Erro: repositório inválido. Agentes obrigatórios ausentes em '%s': %s.\n" \
            "$AGENTS_SOURCE_DIRECTORY" \
            "${missing_agent_names[*]}" >&2
        exit 1
    fi
}

get_symlink_capability() {
    local candidate_directory="$CODEX_HOME_PATH"

    while [[ ! -e "$candidate_directory" ]]; do
        local parent_directory
        parent_directory="$(dirname -- "$candidate_directory")"
        if [[ "$parent_directory" == "$candidate_directory" ]]; then
            printf 'indisponível (não foi possível localizar um diretório gravável)'
            return
        fi
        candidate_directory="$parent_directory"
    done

    if [[ -d "$candidate_directory" && -w "$candidate_directory" ]]; then
        printf 'disponível'
    else
        printf 'indisponível (sem permissão de escrita em %s)' "$candidate_directory"
    fi
}

file_hash() {
    local file_path="$1"
    local hash_value
    local ignored_value

    if ! read -r hash_value ignored_value < <(sha256sum -- "$file_path"); then
        return 1
    fi

    printf '%s' "$hash_value"
}

files_are_equal() {
    local source_path="$1"
    local target_path="$2"
    local source_size
    local target_size
    local source_hash
    local target_hash

    source_size="$(stat -c '%s' -- "$source_path")" || return 1
    target_size="$(stat -c '%s' -- "$target_path")" || return 1
    if [[ "$source_size" != "$target_size" ]]; then
        return 1
    fi

    source_hash="$(file_hash "$source_path")" || return 1
    target_hash="$(file_hash "$target_path")" || return 1
    [[ "$source_hash" == "$target_hash" ]]
}

classify_agent() {
    local agent_name="$1"
    local source_path="$AGENTS_SOURCE_DIRECTORY/$agent_name"
    local target_path="$CODEX_HOME_PATH/$agent_name"
    local link_target
    local resolved_link_target
    local resolved_source_path

    CURRENT_TARGET_PATH="$target_path"
    CURRENT_DETAIL=""

    if [[ -L "$target_path" ]]; then
        link_target="$(readlink -- "$target_path")"
        if [[ "$link_target" != /* ]]; then
            link_target="$(dirname -- "$target_path")/$link_target"
        fi

        resolved_link_target="$(readlink -m -- "$link_target")"
        resolved_source_path="$(readlink -m -- "$source_path")"
        CURRENT_DETAIL="$resolved_link_target"

        if [[ "$resolved_link_target" == "$resolved_source_path" ]]; then
            CURRENT_STATE="SymbolicLink"
            CURRENT_STATUS="[SYMLINK]"
        else
            CURRENT_STATE="SymbolicLinkDifferent"
            CURRENT_STATUS="[SYMLINK DIFERENTE]"
        fi
        return
    fi

    if [[ ! -e "$target_path" ]]; then
        CURRENT_STATE="NotInstalled"
        CURRENT_STATUS="[NÃO INSTALADO]"
        return
    fi

    if [[ ! -f "$target_path" ]]; then
        CURRENT_STATE="Unsupported"
        CURRENT_STATUS="[OBJETO NÃO SUPORTADO]"
        CURRENT_DETAIL="Existe um objeto que não é arquivo nem symlink com o mesmo nome."
        return
    fi

    if files_are_equal "$source_path" "$target_path"; then
        CURRENT_STATE="FileEqual"
        CURRENT_STATUS="[Arquivo IGUAL]"
    else
        CURRENT_STATE="FileDifferent"
        CURRENT_STATUS="[Arquivo DIFERENTE]"
    fi
}

refresh_agent_states() {
    local agent_path
    local agent_name
    local discovered_agent_names=()

    AGENT_NAMES=()
    AGENT_STATES=()
    AGENT_STATUSES=()
    AGENT_DETAILS=()
    AGENT_TARGET_PATHS=()

    shopt -s nullglob
    for agent_path in "$AGENTS_SOURCE_DIRECTORY"/AGENTS*.md; do
        if [[ -f "$agent_path" ]]; then
            discovered_agent_names+=("$(basename -- "$agent_path")")
        fi
    done
    shopt -u nullglob

    if ((${#discovered_agent_names[@]} == 0)); then
        printf "Erro: nenhum arquivo AGENTS*.md encontrado em '%s'.\n" \
            "$AGENTS_SOURCE_DIRECTORY" >&2
        exit 1
    fi

    while IFS= read -r agent_name; do
        classify_agent "$agent_name"
        AGENT_NAMES+=("$agent_name")
        AGENT_STATES+=("$CURRENT_STATE")
        AGENT_STATUSES+=("$CURRENT_STATUS")
        AGENT_DETAILS+=("$CURRENT_DETAIL")
        AGENT_TARGET_PATHS+=("$CURRENT_TARGET_PATH")
    done < <(printf '%s\n' "${discovered_agent_names[@]}" | sort)
}

show_agent_states() {
    local index

    printf '\nInstalador de agentes do Codex\n'
    printf 'Origem:  %s\n' "$AGENTS_SOURCE_DIRECTORY"
    printf 'Destino: %s\n\n' "$CODEX_HOME_PATH"

    for ((index = 0; index < ${#AGENT_NAMES[@]}; index++)); do
        printf '%2d. %s %s\n' \
            "$((index + 1))" \
            "${AGENT_STATUSES[$index]}" \
            "${AGENT_NAMES[$index]}"
    done

    printf ' 0. Sair\n\n'
}

confirm_action() {
    local message="$1"
    local answer=""

    if ! read -r -p "$message [s/N]: " answer; then
        return 1
    fi

    case "${answer,,}" in
        s|sim)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

wait_for_menu() {
    local ignored_value
    read -r -p 'Pressione Enter para continuar: ' ignored_value || true
}

install_agent() {
    local index="$1"
    local agent_name="${AGENT_NAMES[$index]}"
    local source_path="$AGENTS_SOURCE_DIRECTORY/$agent_name"
    local target_path="${AGENT_TARGET_PATHS[$index]}"
    local method=""
    local method_name=""

    printf '\n1. Copiar arquivo\n'
    printf '2. Criar symlink\n'
    printf '0. Voltar\n'
    read -r -p 'Escolha o método de instalação: ' method || return

    case "$method" in
        0)
            return
            ;;
        1)
            method_name="copiar o arquivo"
            ;;
        2)
            method_name="criar o symlink"
            ;;
        *)
            printf 'Aviso: método inválido.\n' >&2
            wait_for_menu
            return
            ;;
    esac

    if ! confirm_action "Confirma instalar $agent_name por meio de $method_name?"; then
        return
    fi

    if ! mkdir -p -- "$CODEX_HOME_PATH"; then
        printf "Aviso: não foi possível criar o diretório '%s'.\n" \
            "$CODEX_HOME_PATH" >&2
        wait_for_menu
        return
    fi

    if [[ "$method" == "1" ]]; then
        if cp -- "$source_path" "$target_path"; then
            printf 'Instalação concluída.\n'
        else
            printf 'Aviso: não foi possível copiar o arquivo.\n' >&2
        fi
    else
        if ln -s -- "$source_path" "$target_path"; then
            printf 'Instalação concluída.\n'
        else
            printf 'Aviso: não foi possível criar o symlink. Verifique as permissões do destino.\n' >&2
        fi
    fi

    wait_for_menu
}

uninstall_agent() {
    local index="$1"
    local agent_name="${AGENT_NAMES[$index]}"
    local state="${AGENT_STATES[$index]}"
    local target_path="${AGENT_TARGET_PATHS[$index]}"

    case "$state" in
        FileDifferent)
            printf "ATENÇÃO: '%s' é diferente do arquivo do repositório e será excluído permanentemente.\n" \
                "$target_path" >&2
            ;;
        SymbolicLinkDifferent)
            printf 'ATENÇÃO: o symlink aponta para outro local. Apenas o link será removido.\n' >&2
            ;;
        SymbolicLink)
            printf 'Apenas o symlink será removido; o arquivo do repositório não será alterado.\n'
            ;;
    esac

    if ! confirm_action "Confirma desinstalar $agent_name?"; then
        return
    fi

    if rm -- "$target_path"; then
        printf 'Desinstalação concluída.\n'
    else
        printf 'Aviso: não foi possível desinstalar o agente.\n' >&2
    fi

    wait_for_menu
}

update_copied_agent() {
    local index="$1"
    local agent_name="${AGENT_NAMES[$index]}"
    local source_path="$AGENTS_SOURCE_DIRECTORY/$agent_name"
    local target_path="${AGENT_TARGET_PATHS[$index]}"

    printf "ATENÇÃO: '%s' é diferente e será sobrescrito pelo arquivo do repositório.\n" \
        "$target_path" >&2
    if ! confirm_action "Confirma atualizar $agent_name?"; then
        return
    fi

    if cp -f -- "$source_path" "$target_path"; then
        printf 'Atualização concluída.\n'
    else
        printf 'Aviso: não foi possível atualizar o arquivo.\n' >&2
    fi

    wait_for_menu
}

update_symbolic_link() {
    local index="$1"
    local agent_name="${AGENT_NAMES[$index]}"
    local source_path="$AGENTS_SOURCE_DIRECTORY/$agent_name"
    local target_path="${AGENT_TARGET_PATHS[$index]}"
    local target_directory
    local temporary_link_path
    local backup_link_path

    printf 'ATENÇÃO: o symlink atual aponta para outro local e será substituído.\n' >&2
    if ! confirm_action "Confirma atualizar $agent_name?"; then
        return
    fi

    target_directory="$(dirname -- "$target_path")"
    temporary_link_path="$target_directory/.$agent_name.$$.$RANDOM.tmp"
    backup_link_path="$target_directory/.$agent_name.$$.$RANDOM.bak"

    if ! ln -s -- "$source_path" "$temporary_link_path"; then
        printf 'Aviso: não foi possível preparar o novo symlink.\n' >&2
        wait_for_menu
        return
    fi

    if ! mv -- "$target_path" "$backup_link_path"; then
        rm -f -- "$temporary_link_path"
        printf 'Aviso: não foi possível preservar o symlink atual.\n' >&2
        wait_for_menu
        return
    fi

    if ! mv -- "$temporary_link_path" "$target_path"; then
        mv -- "$backup_link_path" "$target_path" 2>/dev/null || true
        rm -f -- "$temporary_link_path"
        printf 'Aviso: não foi possível instalar o novo symlink; o anterior foi restaurado.\n' >&2
        wait_for_menu
        return
    fi

    if ! rm -- "$backup_link_path"; then
        printf "Aviso: o symlink foi atualizado, mas o link anterior não pôde ser removido: '%s'.\n" \
            "$backup_link_path" >&2
    fi

    printf 'Atualização concluída.\n'
    wait_for_menu
}

show_installed_agent_actions() {
    local index="$1"
    local state="${AGENT_STATES[$index]}"
    local action=""

    printf '\n%s %s\n' "${AGENT_STATUSES[$index]}" "${AGENT_NAMES[$index]}"
    if [[ -n "${AGENT_DETAILS[$index]}" ]]; then
        printf 'Detalhe: %s\n' "${AGENT_DETAILS[$index]}"
    fi

    if [[ "$state" == "FileDifferent" || "$state" == "SymbolicLinkDifferent" ]]; then
        printf '1. Atualizar\n'
        printf '2. Desinstalar\n'
        printf '0. Voltar\n'
        read -r -p 'Escolha uma ação: ' action || return

        case "$action" in
            1)
                if [[ "$state" == "FileDifferent" ]]; then
                    update_copied_agent "$index"
                else
                    update_symbolic_link "$index"
                fi
                ;;
            2)
                uninstall_agent "$index"
                ;;
            0)
                ;;
            *)
                printf 'Aviso: ação inválida.\n' >&2
                wait_for_menu
                ;;
        esac
        return
    fi

    printf '1. Desinstalar\n'
    printf '0. Voltar\n'
    read -r -p 'Escolha uma ação: ' action || return
    case "$action" in
        1)
            uninstall_agent "$index"
            ;;
        0)
            ;;
        *)
            printf 'Aviso: ação inválida.\n' >&2
            wait_for_menu
            ;;
    esac
}

validate_dependencies
detect_codex_home

printf '\nContexto detectado\n'
printf 'Repositório:      %s\n' "$REPOSITORY_ROOT"
printf 'Diretório Codex:  %s\n' "$CODEX_HOME_PATH"
printf 'Detecção Codex:   %s\n' "$CODEX_HOME_SOURCE"
printf 'Diretório agents: %s\n' "$AGENTS_SOURCE_DIRECTORY"
printf 'Symlink Linux:    %s\n' "$(get_symlink_capability)"

validate_agent_repository
printf 'Validação:        %d arquivos obrigatórios encontrados.\n' \
    "${#REQUIRED_AGENT_FILE_NAMES[@]}"

while true; do
    refresh_agent_states
    show_agent_states

    if [[ "$LIST_ONLY" == true ]]; then
        break
    fi

    selection=""
    selection_number=0
    read -r -p 'Escolha o número de um agente: ' selection || break
    if [[ ! "$selection" =~ ^[0-9]+$ ]]; then
        printf 'Aviso: seleção inválida.\n' >&2
        wait_for_menu
        continue
    fi

    selection_number=$((10#$selection))
    if ((selection_number == 0)); then
        break
    fi

    if ((selection_number < 1 || selection_number > ${#AGENT_NAMES[@]})); then
        printf 'Aviso: seleção fora da lista.\n' >&2
        wait_for_menu
        continue
    fi

    selected_index=$((selection_number - 1))
    case "${AGENT_STATES[$selected_index]}" in
        NotInstalled)
            install_agent "$selected_index"
            ;;
        Unsupported)
            printf 'Aviso: %s %s\n' \
                "${AGENT_STATUSES[$selected_index]}" \
                "${AGENT_DETAILS[$selected_index]}" >&2
            printf 'Aviso: o instalador não alterará esse objeto.\n' >&2
            wait_for_menu
            ;;
        *)
            show_installed_agent_actions "$selected_index"
            ;;
    esac
done
