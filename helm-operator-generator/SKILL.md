---
name: helm-operator-generator
description: Generate a Helm operator from an existing Helm Chart and prepare it for CI/CD. Includes creating the operator with operator-sdk, updating RBAC permissions from chart templates, generating OLM bundle manifests with specific channels, creating Alauda CI configs, and verifying the completion.
---

# Helm Operator Generator

This skill instructs the AI agent on how to generate a Helm-based Kubernetes operator from an existing Helm Chart and prepare all necessary configurations for deployment and CI/CD.

## Workflow Instructions

When the user asks to generate a Helm operator using this skill, perform the following steps carefully in sequence:

### Step 1: Initialize the Helm Operator Project

1. Automatically determine the `domain`, `group`, `version`, and `kind` by parsing the `Chart.yaml` file of the provided Helm Chart (e.g., derive `kind` from the CamelCased chart name, `version` as `v1alpha1`, and sensible defaults for `domain` and `group`). Do NOT ask the user for these parameters. Only ask for the target project name/directory and the path/repository of the existing Helm Chart if they have not provided them.
2. Use the `run_in_terminal` tool to run the following `operator-sdk` command inside the designated directory:
   ```bash
   operator-sdk init --plugins helm --domain <domain> --group <group> --version <version> --kind <kind> --helm-chart <path-or-repo>
   ```

### Step 2: Examine and Update RBAC Permissions

The generated `config/rbac/role.yaml` often misses permissions for the specific resources deployed by the Helm Chart templates.
1. Use `read_file` or `grep_search` to examine the Helm Chart's template files (`helm-charts/<chart-name>/templates/*.yaml`).
2. Identify all Kubernetes `kind`s and their corresponding `apiVersion`s (API groups) that the Helm Chart creates (e.g., Deployments, Services, Ingresses, ConfigMaps, Secrets, RBAC, CustomResources).
3. Update `config/rbac/role.yaml` (using `replace_string_in_file` or `run_in_terminal` via `sed`/`yq`) to add the missing API groups and resources to the manager's ClusterRole rules. Allow `create`, `delete`, `get`, `list`, `patch`, `update`, `watch` verbs for these resources.

### Step 3: Generate Operator Bundle Manifests

Generate the OLM (Operator Lifecycle Manager) bundle manifests.
1. Determine the target Docker image and tag (e.g., `<your-registry>/<image>:<tag>`). If not provided by the user, ask for it or use a placeholder like `example.com/operator:v0.0.1`.
2. Use the `run_in_terminal` tool to run the `make` bundle command:
   ```bash
   make bundle IMG="<image:tag>" CHANNELS=stable
   ```
3. **Important**: The `make bundle` command might be interactive (e.g., asking for the display name, description, provider name, etc.). If you are using a non-interactive shell, ensure you can either pipe inputs (e.g., `echo -e "\n\n\n\n" | make bundle ...`) or run the command and correctly handle the terminal output to provide the needed inputs via the terminal session.

### Step 4: Create Alauda CI Configs

Create standard Alauda CI configurations by copying the reference `build.yaml` and `build.sh` files provided in this skill's `templates/` directory (`/Users/wuyi/awesome-acp-skills/helm-operator-generator/templates/`).
1. Copy `templates/build.yaml` to the root of the newly created operator project.
2. Copy `templates/build.sh` to the root of the project and ensure it has executable permissions (`chmod +x build.sh`).
3. Modify the newly copied `build.yaml` and `build.sh` files exactly as needed for the specific operator project, replacing placeholders (like `<image-name>`, paths, or specific tags) with the actual project's name and Docker registry path. The structure and commands should remain exactly like the referenced files.

### Step 5: Verify Completion Correctness

1. Verify that the project directory was successfully created with all expected subdirectories (`config/`, `helm-charts/`, etc.).
2. Verify that `config/rbac/role.yaml` includes the newly identified API groups from the Helm Chart templates.
3. Verify the existence of the newly generated `bundle/` directory, containing the CSV (ClusterServiceVersion) and CRD manifests.
4. Verify that `build.yaml` and `build.sh` exist and have correct syntax.
5. Report the final status back to the user, providing a summary of the executed steps and confirming readiness for CI/CD deployment.
