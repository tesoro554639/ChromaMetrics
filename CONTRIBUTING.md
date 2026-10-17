# Contributing to ChromaMetrics

Thank you for your interest in contributing to **ChromaMetrics**! We welcome bug reports, feature suggestions, architecture improvements, and code contributions.

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md) in all community interactions.

## Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/ChromaMetrics.git
   cd ChromaMetrics
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run tests to verify setup**:
   ```bash
   flutter test
   ```

## Development Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
2. Follow our commit message guidelines (Conventional Commits):
   - `feat:` for new capabilities
   - `fix:` for bug fixes
   - `docs:` for documentation updates
   - `refactor:` for code restructurings
   - `test:` for test additions or updates
   - `chore:` for tooling or dependency changes
3. Ensure static analysis and tests pass before committing:
   ```bash
   dart analyze
   flutter test
   ```
4. Submit a Pull Request targeting `main`.
