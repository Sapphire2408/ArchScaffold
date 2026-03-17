# Contributing to ArchScaffold

Thanks for your interest in contributing! Here's how to get started.

## Creating a Custom Template

1. Add a new `.txt` file to the `templates/` directory.
2. Use the `=== path/to/directory` syntax to define directories:

```text
# Architecture Name (this header is informational)

=== src/layer-one
# Layer One
Explain the purpose of this layer.

=== src/layer-two
# Layer Two
Explain the purpose of this layer.
```

3. The script auto-discovers new `.txt` files — no code changes needed.

## Running Tests

```bash
bash tests/test_scaffold.sh
```

All tests must pass before submitting a pull request.

## Development Guidelines

- **No dependencies** — keep the script pure bash.
- **Test your changes** — add tests for any new flags or behaviors.
- **Keep templates detailed** — each directory's README should explain *what*, *why*, and *what goes here*.

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-template`)
3. Commit your changes with a descriptive message
4. Push to your fork and open a Pull Request
