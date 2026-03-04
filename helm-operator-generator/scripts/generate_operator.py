#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys


def run_command(command, cwd=None):
    print(f"Executing: {command} in {cwd if cwd else 'current directory'}")
    try:
        subprocess.run(command, check=True, cwd=cwd, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        sys.exit(e.returncode)


def main():
    parser = argparse.ArgumentParser(
        description="Generate a Helm Operator using operator-sdk"
    )
    parser.add_argument("project_name", help="Name of the operator project directory")
    parser.add_argument("--domain", required=True, help="Domain for the API group")
    parser.add_argument("--group", required=True, help="Group name for the API")
    parser.add_argument("--version", required=True, help="API version (e.g., v1alpha1)")
    parser.add_argument("--kind", required=True, help="Kind name for the CRD")
    parser.add_argument("--helm-chart", help="Local path or repo/chart name")
    parser.add_argument("--helm-chart-repo", help="Helm chart repository URL")
    parser.add_argument(
        "--helm-chart-version", help="Specific version of the Helm chart"
    )

    args = parser.parse_args()

    project_dir = os.path.abspath(args.project_name)

    if os.path.exists(project_dir):
        print(f"Error: Directory '{args.project_name}' already exists.")
        sys.exit(1)

    os.makedirs(project_dir)

    cmd_parts = [
        "operator-sdk",
        "init",
        "--plugins",
        "helm",
        "--domain",
        args.domain,
        "--group",
        args.group,
        "--version",
        args.version,
        "--kind",
        args.kind,
    ]

    if args.helm_chart:
        cmd_parts.extend(["--helm-chart", args.helm_chart])

    if args.helm_chart_repo:
        cmd_parts.extend(["--helm-chart-repo", args.helm_chart_repo])

    if args.helm_chart_version:
        cmd_parts.extend(["--helm-chart-version", args.helm_chart_version])

    # Join command parts
    command = " ".join(cmd_parts)

    run_command(command, cwd=project_dir)

    print(f"\nSuccessfully created Helm operator project in: {project_dir}")
    print("\nNext steps:")
    print(f"  cd {args.project_name}")
    print("  make docker-build docker-push IMG=<your-registry>/<image>:<tag>")
    print("  make deploy IMG=<your-registry>/<image>:<tag>")


if __name__ == "__main__":
    main()
