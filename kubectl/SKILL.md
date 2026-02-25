---
name: kubectl
description: Guide for using kubectl, the command-line tool for Kubernetes. This skill should be used when the user wants to manage Kubernetes resources, such as listing pods, getting deployment details, applying YAML configurations, or deleting resources.
---

# Kubectl CLI

This skill covers the usage of `kubectl` for managing Kubernetes clusters.

## Overview

`kubectl` is the standard command-line tool for communicating with a Kubernetes cluster's control plane.

## Common Operations

### Viewing Resources

**List resources**
```bash
# List all pods in the current namespace
kubectl get pods

# List all services in a specific namespace
kubectl get services -n <namespace>

# List all deployments in all namespaces
kubectl get deployments --all-namespaces

# List nodes
kubectl get nodes
```

**Get detailed information**
```bash
# Get details of a specific pod in YAML format
kubectl get pod <pod-name> -o yaml

# Get details in JSON format
kubectl get pod <pod-name> -o json

# Describe a resource (shows events and status)
kubectl describe pod <pod-name>
kubectl describe node <node-name>
```

### Creating and Updating Resources

**Apply configuration**
The most common way to manage resources is using YAML files.

```bash
# Create or update resources from a YAML file
kubectl apply -f <filename.yaml>

# Create or update resources from a directory of YAML files
kubectl apply -f <directory>/

# Apply from a remote URL
kubectl apply -f https://example.com/manifest.yaml
```

**Imperative commands**
```bash
# Create a namespace
kubectl create namespace <namespace-name>

# Create a configmap
kubectl create configmap <name> --from-literal=key=value

# Create a secret
kubectl create secret generic <name> --from-literal=password=123
```

### Deleting Resources

```bash
# Delete resources defined in a YAML file
kubectl delete -f <filename.yaml>

# Delete a specific resource by name
kubectl delete pod <pod-name>
kubectl delete service <service-name>

# Delete all resources of a type in a namespace
kubectl delete pods --all -n <namespace>
```

### Troubleshooting

```bash
# view logs of a pod
kubectl logs <pod-name>

# View logs of a specific container in a pod
kubectl logs <pod-name> -c <container-name>

# Stream logs
kubectl logs -f <pod-name>

# Execute a command in a container
kubectl exec -it <pod-name> -- /bin/bash
```

### Context and Configuration

```bash
# View current config
kubectl config view

# Switch context (cluster)
kubectl config use-context <context-name>

# Set default namespace for current context
kubectl config set-context --current --namespace=<namespace>
```
