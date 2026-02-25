# Violet Package Upload

This skill provides instructions for using the `violet` CLI tool to upload software packages (Operators, Cluster Plugins, and Helm Charts) to the platform.

## Overview

The `violet` CLI tool allows you to upload software packages from your custom portal to the platform. It supports three types of packages:
- Operators
- Cluster Plugins
- Helm Charts

## Prerequisites

Before using the `violet` CLI, ensure you have:
1.  The `violet` CLI tool installed and accessible in your path.
2.  A valid platform user account with the **System** role property and the **platform-admin-system** role name.
3.  The following information:
    -   Platform access address (`--platform-address`)
    -   Platform username (`--platform-username`)
    -   Platform password (`--platform-password`)

## Usage

The general syntax for uploading a package is:

```bash
violet push <package_path> --platform-address <address> --platform-username <username> --platform-password <password> [options]
```

### 1. Uploading Operators

Use this command to upload an Operator package.

**Command:**
```bash
violet push <operator_package.tgz> \
  --platform-address <address> \
  --platform-username <username> \
  --platform-password <password> \
  [--clusters <cluster_list>] \
  [--target-chartrepo <repo>] \
  [--force] \
  [--skip-push]
```

**Specific Options:**
-   `--clusters`: (Optional) Specify which clusters to upload to (comma-separated, e.g., `global,cluster1`). Defaults to `global` if omitted.
-   `--target-chartrepo`: (Optional) Upload to a specific catalog source.

### 2. Uploading Cluster Plugins

Use this command to upload a Cluster Plugin package.

**Command:**
```bash
violet push <plugin_package.tgz> \
  --platform-address <address> \
  --platform-username <username> \
  --platform-password <password> \
  [--force] \
  [--skip-push]
```

**Note:** Uploading cluster plugins does not support the `--clusters` parameter. To upload only to the `global` cluster, you must configure `ModulePlugin`.

### 3. Uploading Helm Charts

Use this command to upload a Helm Chart package.

**Command:**
```bash
violet push <chart_package.tgz> \
  --platform-address <address> \
  --platform-username <username> \
  --platform-password <password> \
  [--force] \
  [--skip-push]
```

**Note:** The upload process does not support specifying a template repository. Packages are uploaded to `public-charts` by default.

## Common Parameters

| Parameter | Description |
| :--- | :--- |
| `args[0]` | **Required**. The file path of the package to upload. For multiple packages, specify the directory path. |
| `--platform-address` | **Required**. The access address of the platform. |
| `--platform-username` | **Required**. Username of a local user with the `Platform Administrator role`. |
| `--platform-password` | **Required**. Password for the username. |
| `--skip-push` | **Optional**. Create upload-related resources without pushing images. |
| `--force` | **Optional**. Forcibly overwrite and update related resources if images already exist. |
| `--debug` | **Optional**. Print debug log information. |
