# Contributing to Enterprise AWS DevSecOps Platform

Thank you for your interest in contributing to the **Enterprise AWS DevSecOps Platform**! This guide outlines the development standards, repository structure, and contribution workflow.

---

## Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free experience for everyone. Please be respectful, constructive, and collaborative.

---

## Development Standards & Guidelines

### 1. Application (Spring Boot)
- **Java Version:** OpenJDK 21.
- **Build Tool:** Maven (use the included `./mvnw` wrapper).
- **Testing:** Write unit tests for business logic and integration tests for REST API endpoints using `@SpringBootTest` and `MockMvc`.
- **Code Quality:** Ensure all tests pass before submitting a pull request:
  ```bash
  cd application
  ./mvnw clean test
  ```

### 2. Infrastructure as Code (Terraform)
- **Terraform Version:** >= 1.5.0.
- **Formatting:** All Terraform files must be formatted with standard indentation:
  ```bash
  terraform fmt -recursive terraform/
  ```
- **Modularity:** Place reusable components under `terraform/modules/<component>` and environment compositions under `terraform/environments/<env>`.
- **Security:** Do not commit sensitive data or hardcoded credentials. Use AWS Secrets Manager, IAM Roles for Service Accounts (IRSA), or EKS Pod Identity.

### 3. Containerization (Docker)
- Keep image sizes minimal with multi-stage builds.
- Always run containers as a non-root system user.
- Add explicit `HEALTHCHECK` instructions.
- Test container builds locally:
  ```bash
  docker build -t devsecops-platform:test -f application/Dockerfile application
  ```

### 4. Kubernetes & Helm
- Store charts under `helm/<chart-name>`.
- Parameterize configurable values in `values.yaml`. Avoid hardcoding environment-specific identifiers (e.g. AWS Account IDs).
- Validate charts with:
  ```bash
  helm lint helm/application
  ```

---

## Contribution Workflow

1. **Fork or Branch**:
   - Create a feature branch from `main`:
     ```bash
     git checkout -b feature/my-new-feature
     ```
2. **Make Changes**:
   - Keep commits focused and provide clear, descriptive commit messages following the Conventional Commits specification (e.g., `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
3. **Verify Locally**:
   - Ensure application tests pass.
   - Run `terraform fmt` and security checks if modifying IaC.
4. **Submit a Pull Request**:
   - Open a PR against `main`.
   - Provide a clear summary of your changes, motivation, and any testing performed.

---

## Reporting Issues

If you find a bug, vulnerability, or have a feature proposal, please open an Issue with:
- A clear, descriptive title.
- Steps to reproduce the issue (if applicable).
- Expected vs. actual behavior.
- Environment details (OS, Terraform/Helm/Java version).
