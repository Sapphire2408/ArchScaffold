# ArchScaffold 🏗️

ArchScaffold is a lightweight, customizable, and zero-dependency bash script to instantly scaffold common software architecture patterns.

Instead of manually creating boilerplate directories and writing architecture-specific `README.md` files yourself, ArchScaffold generates comprehensive, cleanly structured directories and embeds explanatory documentation in each layer of your chosen architecture.

## Features

- **No Dependencies:** Pure bash script—no Node.js, Python, or Ruby required.
- **Template-Based:** Architectures are defined using simple text templates, making it trivial to add custom patterns.
- **Self-Documenting:** Each generated folder includes a `README.md` explaining the purpose of that specific architectural layer.
- **Interactive Menu:** Run the script without arguments for an easy-to-use interactive prompt.

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

#### Options:
- `-n, --name NAME` : The name of the project (creates a new directory).
- `-a, --arch ARCH` : The architecture template to use (name without `.txt`).
- `-d, --dry-run` : Preview what directories and files would be created without making actual changes to the disk.
- `-h, --help` : Show help and usage information.

## Creating Custom Templates

ArchScaffold generates directories based on simple `.txt` files located in the `templates/` directory.

To create your own architecture template, simply add a new text file to the `templates/` folder using the following format:

```text
# Global README Header
(Any text before the first "===" is ignored by the parser but useful for comments)

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

ArchScaffold includes its own unit tests to verify CLI arguments and directory generation behavior. 

To run the tests, execute:
```bash
bash tests/test_scaffold.sh
```

## License

MIT License. See `LICENSE` for more information.
