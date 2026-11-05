# Contributing to the Terraform OCI Always Free & Flexible HA Compute Stack (IaC)

Thank you for considering contributing! 🎉

This repository is an Always Free optimized, flexible OCI Terraform module (Infrastructure as Code) published on the Terraform Registry. It is built and tested with Terraform and stays OpenTofu-compatible. We welcome contributions, bug reports, improvements, and suggestions.

## Table of Contents

- [How to Contribute](#how-to-contribute)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)
- [Security](#security)
- [License](#license)

## How to Contribute

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/terraform-oci-alwaysfree-and-flexible-ha-compute-service.git
   cd terraform-oci-alwaysfree-and-flexible-ha-compute-service
   ```
3. **Create a new branch** for your feature or fix:
   ```bash
   git checkout -b feature/my-feature
   ```
4. **Make your changes** in the appropriate module folder.
5. **Run pre-commit hooks** locally to ensure code quality:
   ```bash
   pre-commit run --all-files
   ```
6. **Test your changes** (terraform fmt, validate, tflint, checkov, terraform-docs). If you changed variables or outputs, regenerate the docs with `terraform-docs -c .terraform-docs.yml <dir>`.
7. **Commit your changes**.
8. **Push** to your fork and open a Pull Request.

## Code Standards

To maintain quality and consistency, please adhere to the following standards:

- **Terraform Formatting**: All files must be formatted using `terraform fmt -recursive`.
- **Validation**: Ensure the configuration is valid with `terraform validate`.
- **Linting**: Use [TFLint](https://github.com/terraform-linters/tflint) to check for errors and best practices.
- **Security**: Run security scans using [Checkov](https://github.com/bridgecrewio/checkov).
- **Documentation**: Keep variables, locals, and outputs well-documented with descriptions.

## Testing

- Verify that all examples under `examples/` work correctly with your changes.
- Run the full pre-commit pipeline locally before pushing.
- Ensure that the CI/CD pipeline passes after submitting your Pull Request.
- Terratest deploys real OCI resources and only runs on `main` (or manually): it needs OCI credentials, which are not available to pull requests from forks. If you have an OCI tenancy, run the smoke test locally (see [test/README.md](test/README.md)) and paste the result in your PR.
- Changes that affect cost must keep `free_tier_mode = true` within the Always Free limits (see `validations.tf`).

## Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat`: A new feature
- `fix`: A bug fix
- `chore`: Changes to the build process, CI, documentation, etc.
- `docs`: Documentation only changes
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests

**Example:**
```text
feat: add optional free_tier_mode validation for compute instances
```

## Pull Requests

1. Open a Pull Request against the `main` branch.
2. Provide a clear and concise description of your changes.
3. Reference any related issues (e.g., `Closes #123`).
4. Ensure your PR passes all CI checks.

## Security

If you discover a security vulnerability, please **do not** open a public issue.

- Report it privately through GitHub: **Security** tab → **Report a vulnerability** (private vulnerability reporting).
- We follow responsible disclosure best practices.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
