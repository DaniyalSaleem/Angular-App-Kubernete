# AngularApp

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 6.0.8.

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `--prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).

## CI/CD

### Overview

This repository uses **Azure Pipelines** for all CI/CD operations (`azure-pipelines.yml`).

### Pipeline triggers

| Event | Stages that run |
|---|---|
| Push to `master` | Lint → Test → Build → Docker build/scan/push → Deploy to AKS |
| Push of a `v*` Git tag | Same as master, plus Docker image is tagged with the version |
| Pull request to any branch | Lint → Test → Build only (no Docker push, no Deploy) |

### Stages

1. **Lint, Test & Build**
   - Installs with `npm ci` using a pinned Node.js version (deterministic installs).
   - Runs `npm run lint`.
   - Runs `npm audit --audit-level=high` — fails if HIGH or CRITICAL npm vulnerabilities are found.
   - Runs unit tests in `ChromeHeadlessNoSandbox` (headless, no sandbox for CI).
   - Publishes Cobertura code-coverage results as a pipeline artifact.
   - Runs `npm run build -- --prod` (production build).

2. **Docker Build & Scan**
   - Builds the Docker image locally.
   - Scans the image with [Trivy](https://github.com/aquasecurity/trivy) — fails on HIGH or CRITICAL vulnerabilities.
     Known/accepted CVEs can be suppressed by adding their IDs to `.trivyignore`.
   - Pushes to Azure Container Registry (ACR) on `master` and `v*` tag builds.

3. **Deploy to AKS** *(master and `v*` tag builds only)*
   - Deploys the new image to Azure Kubernetes Service using the manifests in `manifests/`.

### Docker image tagging

Every image pushed to ACR receives two immutable SHA-based tags:

| Tag | Example |
|---|---|
| Full commit SHA | `containerkube.azurecr.io/angularappkubernetes:abc1234def567890...` |
| Short SHA (8 chars) | `containerkube.azurecr.io/angularappkubernetes:abc1234d` |

When the build is triggered by a Git version tag (e.g. `v1.2.3`), the image also receives the version tag:

| Tag | Example |
|---|---|
| Version tag | `containerkube.azurecr.io/angularappkubernetes:v1.2.3` |

### Creating a release

```bash
# Tag and push — triggers the full pipeline and publishes the version-tagged image
git tag v1.2.3
git push origin v1.2.3
```

The pipeline will:
1. Run lint, tests, and production build.
2. Build the Docker image and scan it with Trivy.
3. Push images tagged `v1.2.3`, the full commit SHA, and the short SHA to ACR.
4. Deploy to AKS.
