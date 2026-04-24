# Contributing

Thank you for your interest in contributing!

## Development setup

```bash
git clone https://github.com/kashif415/REPO.git
cd REPO
mamba env create -f environment.yml
mamba activate ENV_NAME
pre-commit install
```

## Pull requests

1. Fork the repo and create a feature branch from `main`
2. Make your changes with clear commit messages
3. Add or update tests
4. Run the full test suite: `pytest tests/`
5. Run linters: `pre-commit run --all-files`
6. Open a PR with a description of what changed and why

## Code style

- Python: black (line length 100), ruff, type hints where reasonable
- Commit messages: conventional commits (`feat:`, `fix:`, `docs:`, `test:`)

## Reporting bugs

Open an issue with:
- Minimal reproducible example
- Expected vs actual behavior
- Environment (OS, Python version, package versions)
