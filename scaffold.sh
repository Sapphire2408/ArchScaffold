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
VERBOSE=false
FORCE=false
LIST_ONLY=false
OUTPUT_DIR="."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${ARCHSCAFFOLD_TEMPLATES_DIR:-$SCRIPT_DIR/templates}"

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          🏗️  Software Architecture Scaffolder            ║"
    echo "║                   v3.0 (Enhanced)                       ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME         Project name"
    echo "  -a, --arch ARCH         Architecture template (name without .txt)"
    echo "  -o, --output-dir DIR    Output directory (default: current directory)"
    echo "  -d, --dry-run           Preview what would be created"
    echo "  -l, --list              List available architecture templates"
    echo "  -v, --verbose           Show detailed output during scaffolding"
    echo "  -f, --force             Overwrite existing project directory"
    echo "  -h, --help              Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  ARCHSCAFFOLD_TEMPLATES_DIR   Custom templates directory"
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

list_template_names() {
    for f in "$TEMPLATES_DIR"/*.txt; do
        if [ -f "$f" ]; then
            basename "$f" .txt
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

validate_project_name() {
    local name="$1"
    if [ -z "$name" ]; then
        echo -e "${RED}[ERROR]${NC} Project name cannot be empty."
        exit 1
    fi
    if [[ ! "$name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        echo -e "${RED}[ERROR]${NC} Invalid project name '${name}'."
        echo "       Use only letters, numbers, dashes, underscores, and dots."
        exit 1
    fi
}

parse_template() {
    local template_file="$1"
    local project_dir="$2"
    local dry_run="$3"
    local verbose="$4"

    local out=""
    local dirs_count=0
    local files_count=0
    local arch_name
    arch_name=$(basename "$template_file" .txt)
    local header_text=""
    local in_header=true

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        if [[ "$line" =~ ^===\ (.+)$ ]]; then
            in_header=false
            dir="${BASH_REMATCH[1]}"
            dir_path="$project_dir/$dir"

            if [ "$dry_run" = true ]; then
                echo -e "  ${YELLOW}📁 $dir_path${NC}"
                echo -e "  ${CYAN}📄 $dir_path/README.md${NC}"
                continue
            fi

            mkdir -p "$dir_path"
            out="$dir_path/README.md"
            : > "$out"
            dirs_count=$((dirs_count + 1))
            files_count=$((files_count + 1))

            if [ "$verbose" = true ]; then
                echo -e "  ${GREEN}✓${NC} Created ${BOLD}$dir_path/${NC}"
                echo -e "  ${GREEN}✓${NC} Created ${CYAN}$dir_path/README.md${NC}"
            fi
        elif [ "$in_header" = true ]; then
            header_text+="$line"$'\n'
        elif [ -n "$out" ] && [ "$dry_run" = false ]; then
            printf '%s\n' "$line" >> "$out"
        fi
    done < "$template_file"

    # Generate root README.md for the project
    if [ "$dry_run" = true ]; then
        echo -e "  ${CYAN}📄 $project_dir/README.md${NC}"
    else
        {
            echo "# ${PROJECT_NAME}"
            echo ""
            echo "This project was scaffolded using [ArchScaffold](https://github.com/yourusername/ArchScaffold) with the **${arch_name}** architecture pattern."
            echo ""
            if [ -n "$header_text" ]; then
                echo "$header_text"
                echo ""
            fi
            echo "## Project Structure"
            echo ""
            echo '```'
            # List first-level directories
            for d in "$project_dir"/*/; do
                if [ -d "$d" ]; then
                    echo "├── $(basename "$d")/"
                fi
            done
            echo '```'
            echo ""
            echo "See each directory's \`README.md\` for detailed documentation on its purpose."
        } > "$project_dir/README.md"
        files_count=$((files_count + 1))

        if [ "$verbose" = true ]; then
            echo -e "  ${GREEN}✓${NC} Created ${CYAN}$project_dir/README.md${NC} (project root)"
        fi
    fi

    if [ "$dry_run" = false ]; then
        find "$project_dir" -name "README.md" -exec perl -0777 -pi -e 's/\s+$/\n/' {} + 2>/dev/null || true
        echo ""
        echo -e "${GREEN}[OK]${NC} Done! Created $dirs_count directories, $files_count README.md files in $project_dir/"
    else
        echo ""
        echo -e "${GREEN}[OK]${NC} Preview complete. Run again without --dry-run to create."
    fi
}

# ─── Parse CLI ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name)
            PROJECT_NAME="$2"; shift 2 ;;
        -a|--arch)
            ARCHITECTURE="$2"; shift 2 ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"; shift 2 ;;
        -d|--dry-run)
            DRY_RUN=true; shift ;;
        -l|--list)
            LIST_ONLY=true; shift ;;
        -v|--verbose)
            VERBOSE=true; shift ;;
        -f|--force)
            FORCE=true; shift ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            usage; exit 1 ;;
    esac
done

# ─── Template Directory Check ────────────────────────────────────────────────
if [ ! -d "$TEMPLATES_DIR" ] || [ -z "$(ls -A "$TEMPLATES_DIR"/*.txt 2>/dev/null)" ]; then
    echo -e "${RED}[ERROR]${NC} No templates found in $TEMPLATES_DIR."
    exit 1
fi

# ─── List Mode ───────────────────────────────────────────────────────────────
if [ "$LIST_ONLY" = true ]; then
    echo -e "${BOLD}Available Architecture Templates:${NC}"
    echo ""
    list_templates
    exit 0
fi

print_banner

# ─── Interactive Setup ───────────────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
    echo -ne "${BOLD}Project name: ${NC}"
    read -r PROJECT_NAME
fi

validate_project_name "$PROJECT_NAME"

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

# ─── Resolve Output Path ────────────────────────────────────────────────────
project_dir="$OUTPUT_DIR/$PROJECT_NAME"

# ─── Overwrite Protection ───────────────────────────────────────────────────
if [ -d "$project_dir" ] && [ "$DRY_RUN" = false ]; then
    if [ "$FORCE" = true ]; then
        echo -e "${YELLOW}[WARN]${NC} Directory '$project_dir' exists. Overwriting (--force)."
        rm -rf "$project_dir"
    else
        echo -e "${RED}[ERROR]${NC} Directory '$project_dir' already exists."
        echo "       Use --force to overwrite."
        exit 1
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[INFO] DRY RUN — nothing will be created:${NC}"
    echo ""
fi

arch_name=$(basename "$selected_template" .txt)
echo -e "${CYAN}Scaffolding '$arch_name' into $project_dir/${NC}"

if [ "$DRY_RUN" = false ]; then
    mkdir -p "$project_dir"
fi

parse_template "$selected_template" "$project_dir" "$DRY_RUN" "$VERBOSE"