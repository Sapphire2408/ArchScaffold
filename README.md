# ArchScaffold 🏗️

ArchScaffold is a lightweight, customizable, and zero-dependency bash script to instantly scaffold common software architecture patterns.

Instead of manually creating boilerplate directories and writing architecture-specific `README.md` files yourself, ArchScaffold generates comprehensive, cleanly structured directories and embeds explanatory documentation in each layer of your chosen architecture.

## Features

- **No Dependencies:** Pure bash script
- **Educational Masterclasses:** Generates a root `README.md` for your project containing a complete educational guide to the chosen architecture (with Mermaid diagrams, trade-offs, and principles).
- **Template-Based:** Architectures are defined using simple text templates, making it trivial to add custom patterns.
- **Self-Documenting:** Each generated folder includes a `README.md` explaining the purpose of that specific architectural layer.
- **Interactive Menu:** Run the script without arguments for an easy-to-use interactive prompt.
- **Input Validation:** Project names are validated to prevent path traversal and injection attacks.
- **Overwrite Protection:** Existing directories are protected by default; use `--force` to overwrite.
- **Custom Template Paths:** Use the `ARCHSCAFFOLD_TEMPLATES_DIR` environment variable to point to your own templates.

## Supported Architectures

ArchScaffold currently comes bundled with the following templates:

- Clean Architecture
- Hexagonal Architecture (Ports & Adapters)
- Onion Architecture
- Layered (N-Tier) Architecture
- CQRS (Command Query Responsibility Segregation)
- Event-Driven Architecture
- Modular Monolith
- Vertical Slice Architecture

## Installation

Clone the repository and run the script directly:

```bash
git clone https://github.com/yourusername/ArchScaffold.git
cd ArchScaffold
```

*(Optional)* You can symlink `scaffold.sh` to your `/usr/local/bin` to make it accessible globally:
```bash
ln -s $(pwd)/scaffold.sh /usr/local/bin/archscaffold
```

## Usage

### Interactive Mode

Simply run the script with no arguments to enter interactive mode:

```bash
./scaffold.sh
```

You will be prompted to enter a project name and select an architecture template from the available choices.

### Command-Line Mode

You can bypass the interactive menu by using command-line arguments:

```bash
./scaffold.sh --name my_new_project --arch hexagonal
```

### List Available Templates

```bash
./scaffold.sh --list
```

### Scaffold with Verbose Output

```bash
./scaffold.sh --name my_project --arch clean --verbose
```

### Scaffold into a Custom Directory

```bash
./scaffold.sh --name my_project --arch clean --output-dir /path/to/workspace
```

### Overwrite an Existing Project

```bash
./scaffold.sh --name my_project --arch clean --force
```

### Options

| Flag | Description |
|------|-------------|
| `-n, --name NAME` | The name of the project (creates a new directory) |
| `-a, --arch ARCH` | The architecture template to use (name without `.txt`) |
| `-o, --output-dir DIR` | Output directory (default: current directory) |
| `-d, --dry-run` | Preview what would be created without writing to disk |
| `-l, --list` | List all available architecture templates |
| `-v, --verbose` | Show detailed output for each created directory and file |
| `-f, --force` | Overwrite existing project directory |
| `-h, --help` | Show help and usage information |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `ARCHSCAFFOLD_TEMPLATES_DIR` | Path to a custom templates directory |

## Creating Custom Templates

ArchScaffold generates directories based on simple `.txt` files located in the `templates/` directory.

To create your own architecture template, simply add a new text file to the `templates/` folder using the following format:

```text
# Any Markdown Title
All content placed at the very top of the file (before the first "===" marker) will be automatically injected into the root README.md of the generated project. This is the perfect place to include an architectural masterclass, Mermaid diagrams, and usage guidelines for the project.

=== src/domain
# Domain Layer
Explain what goes in the domain layer here.
This text becomes the README.md content inside the src/domain folder.

=== src/application
# Application Layer
Explain what goes in the application layer here.
This text becomes the README.md content inside the src/application folder.
```

The script will automatically detect new `.txt` files in the `templates/` folder and make them available in the CLI menu!

## Testing

ArchScaffold includes a comprehensive Bats (Bash Automated Testing System) test suite covering CLI arguments, input validation, directory generation, and all template scaffolding.

To run the tests, execute:
```bash
bats tests/test_scaffold.bats
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on creating templates and submitting changes.

## License

MIT License. See [LICENSE](LICENSE) for more information.
