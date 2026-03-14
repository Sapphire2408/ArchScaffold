#!/usr/bin/env bash
set -euo pipefail

# ─── Colors & Formatting ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Globals ─────────────────────────────────────────────────────────────────
PROJECT_NAME=""
ARCHITECTURE=""
DRY_RUN=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          🏗️  Software Architecture Scaffolder            ║"
    echo "║                   v2.0 (Templates)                       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME         Project name"
    echo "  -a, --arch ARCH         Architecture template (name without .txt)"
    echo "  -d, --dry-run           Preview what would be created"
    echo "  -h, --help              Show this help"
    echo ""
    echo "Interactive mode is started if no arguments are provided."
}

list_templates() {
    local index=1
    for f in "$TEMPLATES_DIR"/*.txt; do
        if [ -f "$f" ]; then
            arch_name=$(basename "$f" .txt)
            echo -e "  ${GREEN}$index)${NC}  $arch_name"
            index=$((index + 1))
        fi
    done
}

get_template_by_index() {
    local index=$1
    local current=1
    for f in "$TEMPLATES_DIR"/*.txt; do
        if [ -f "$f" ]; then
            if [ "$current" -eq "$index" ]; then
                echo "$f"
                return 0
            fi
            current=$((current + 1))
        fi
    done
    return 1
}

# ─── Parse CLI ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name)
            PROJECT_NAME="$2"; shift 2 ;;
        -a|--arch)
            ARCHITECTURE="$2"; shift 2 ;;
        -d|--dry-run)
            DRY_RUN=true; shift ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            usage; exit 1 ;;
    esac
done

print_banner

if [ ! -d "$TEMPLATES_DIR" ] || [ -z "$(ls -A "$TEMPLATES_DIR"/*.txt 2>/dev/null)" ]; then
    echo -e "${RED}[ERROR]${NC} No templates found in $TEMPLATES_DIR."
    exit 1
fi

# ─── Interactive Setup ───────────────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
    echo -ne "${BOLD}Project name: ${NC}"
    read -r PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}[ERROR]${NC} Project name cannot be empty."
    exit 1
fi

if [ -z "$ARCHITECTURE" ]; then
    echo ""
    echo -e "${BOLD}Available Architectures:${NC}"
    echo ""
    list_templates
    echo ""
    echo -ne "${BOLD}Choose architecture template number: ${NC}"
    read -r choice
    echo ""

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[ERROR]${NC} Invalid choice. Must be a number."
        exit 1
    fi

    selected_template=$(get_template_by_index "$choice")
    if [ -z "$selected_template" ]; then
        echo -e "${RED}[ERROR]${NC} Invalid selection."
        exit 1
    fi
else
    selected_template="$TEMPLATES_DIR/$ARCHITECTURE.txt"
    if [ ! -f "$selected_template" ]; then
        echo -e "${RED}[ERROR]${NC} Template '$ARCHITECTURE' not found."
        echo "Available templates:"
        list_templates
        exit 1
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[INFO] DRY RUN — nothing will be created:${NC}"
    echo ""
fi

arch_name=$(basename "$selected_template" .txt)
echo -e "${CYAN}Scaffolding '$arch_name' into ./$PROJECT_NAME/${NC}"

if [ "$DRY_RUN" = false ]; then
    mkdir -p "$PROJECT_NAME"
fi

out=""
dirs_count=0
files_count=0

while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^===\ (.+)$ ]]; then
        dir="${BASH_REMATCH[1]}"
        dir_path="$PROJECT_NAME/$dir"
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${YELLOW}📁 $dir_path${NC}"
            echo -e "  ${CYAN}📄 $dir_path/README.md${NC}"
            continue
        fi

        mkdir -p "$dir_path"
        out="$dir_path/README.md"
        : > "$out"
        dirs_count=$((dirs_count + 1))
        files_count=$((files_count + 1))
    elif [ -n "$out" ] && [ "$DRY_RUN" = false ]; then
        printf '%s\n' "$line" >> "$out"
    fi
done < "$selected_template"

if [ "$DRY_RUN" = false ]; then
    find "$PROJECT_NAME" -name "README.md" -exec perl -0777 -pi -e 's/\s+$/\n/' {} + 2>/dev/null || true
    echo ""
    echo -e "${GREEN}[OK]${NC} Done! Created $dirs_count directories, $files_count README.md files in ./$PROJECT_NAME/"
else
    echo ""
    echo -e "${GREEN}[OK]${NC} Preview complete. Run again without --dry-run to create."
fi