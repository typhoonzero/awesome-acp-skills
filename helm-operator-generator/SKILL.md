---
name: helm-operator-generator
description: This skill automates the creation of a Helm-based Kubernetes Operator. It encapsulates the `operator-sdk init` workflow, allowing users to quickly scaffold a new operator project from an existing Helm chart or a boilerplate chart. Use this skill when you need to wrap a Helm chart into an operator without manually running `operator-sdk init` commands.
license: MIT
---

# Helm Operator Generator

This skill provides a streamlined way to generate a Helm-based Kubernetes Operator project.

## Overview

Creating a Helm operator typically involves running complex `operator-sdk` commands with multiple flags. This skill simplifies that process by providing a script that takes the essential parameters and executes the initialization for you.

## Capabilities

-   **Scaffold Project**: Creates a new directory with the complete structure for a Helm operator.
-   **Helm Chart Integration**: Supports using local charts, repository charts, or boilerplate charts.
-   **Customization**: Allows specifying API group, version, and kind.

## Usage

This skill includes a Python script `scripts/generate_operator.py` that wraps the `operator-sdk` command.

### Prerequisites

Ensure you have the following installed:
-   `operator-sdk` (installed in your PATH)
-   `helm` (if using charts from repositories)
-   `kubectl` (for deploying the operator)

### Generating an Operator

To generate a new operator project, run the script from the terminal (assuming you are in the `helm-operator-skill` directory):

```bash
python3 scripts/generate_operator.py <project_name> \
  --domain <domain> \
  --group <group> \
  --version <version> \
  --kind <kind> \
  [--helm-chart <chart>] \
  [--helm-chart-repo <repo_url>] \
  [--helm-chart-version <chart_version>]
```

#### Examples

**1. Create a basic operator with the default Nginx chart:**

```bash
python3 scripts/generate_operator.py nginx-operator \
  --domain example.com \
  --group demo \
  --version v1alpha1 \
  --kind Nginx
```

**2. Create an operator from an existing local Helm chart:**

```bash
python3 scripts/generate_operator.py my-app-operator \
  --domain my.org \
  --group apps \
  --version v1 \
  --kind MyApp \
  --helm-chart ./charts/my-app
```

**3. Create an operator from a remote Helm chart repository:**

```bash
python3 scripts/generate_operator.py redis-operator \
  --domain example.com \
  --group cache \
  --version v1alpha1 \
  --kind Redis \
  --helm-chart-repo https://charts.bitnami.com/bitnami \
  --helm-chart redis
```

## After Generation

Once the project is generated:

1.  Navigate into the project directory: `cd <project_name>`
2.  Build and push the image: `make docker-build docker-push IMG=<your-registry>/<image>:<tag>`
3.  Deploy the operator: `make deploy IMG=<your-registry>/<image>:<tag>`
