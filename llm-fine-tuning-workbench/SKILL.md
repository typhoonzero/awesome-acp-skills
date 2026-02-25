---
name: llm-fine-tuning-workbench
description: This skill should be used when users want to fine-tune Large Language Models (LLMs) using Alauda AI Workbench, manage fine-tuning tasks, or troubleshoot issues related to model training, dataset preparation, and VolcanoJob execution.
---

# LLM Fine-Tuning Workbench

## Overview

This skill enables the fine-tuning of Large Language Models (LLMs) using Alauda AI Workbench. It provides workflows for preparing models and datasets, building runtime images, submitting and managing VolcanoJob tasks, and troubleshooting common issues during the fine-tuning process.

## Workflow Decision Tree

To fine-tune an LLM using Alauda AI Workbench, follow these steps:

1. **Prepare the Environment**: Create a Notebook/VSCode instance.
2. **Prepare the Model**: Download the base model and upload it to the model repository. Create an empty model for the output.
3. **Prepare the Dataset**: Download the dataset and push it to the dataset repository.
4. **Prepare the Runtime Image**: Build the training runtime image using the provided `Containerfile`.
5. **Create and Submit the Task**: Configure and submit a `VolcanoJob` YAML file.
6. **Manage the Task**: Monitor the task status, view logs, and troubleshoot issues.
7. **Experiment Tracking**: Use MLFlow to track and compare experiments.
8. **Launch Inference Service**: Publish the fine-tuned model as an inference service.

## Step 1: Prepare the Environment

Create a Notebook/VSCode instance in Alauda AI Workbench. It is recommended to request only CPU resources for the Notebook, as the actual fine-tuning task will be submitted to the cluster and request GPU resources.

## Step 2: Prepare the Model

1. Download the base model (e.g., `Qwen/Qwen3-0.6B`) from Huggingface or another source.
2. Upload the model to the Alauda AI model repository.
3. Create an empty model in the model repository to store the fine-tuned output model. Note its Git repository URL.

## Step 3: Prepare the Dataset

1. Create an empty dataset repository in Alauda AI.
2. Upload your dataset (e.g., `identity-alauda`) to the Notebook, unzip it, and push it to the dataset repository using `git lfs`.
3. Ensure the dataset format is compatible with the fine-tuning framework (e.g., Huggingface `datasets` or LLaMA-Factory format).

## Step 4: Prepare the Runtime Image

Use the provided `assets/Containerfile` to build the training runtime image. This image includes necessary dependencies like `git-lfs`, `LLaMA-Factory`, `transformers`, and `mlflow`.

To build and push the image:
```bash
docker build -t <your-registry>/fine_tune_with_llamafactory:v0.1.0 -f assets/Containerfile .
docker push <your-registry>/fine_tune_with_llamafactory:v0.1.0
```

## Step 5: Create and Submit the Task

Use the provided `assets/vcjob-sft.yaml` template to create a `VolcanoJob` task.

Before submitting, modify the following settings in the YAML file:
- `BASE_MODEL_URL`: Git URL of the base model.
- `DATASET_URL`: Git URL of the dataset.
- `OUTPUT_MODEL_URL`: Git URL of the empty output model.
- `MLFLOW_TRACKING_URI`: URL of your MLFlow tracking server.
- `MLFLOW_EXPERIMENT_NAME`: Name of your MLFlow experiment.
- Resource requests/limits (CPU, Memory, GPU).
- Storage configurations (e.g., `models-cache` PVC).

Submit the task:
```bash
kubectl create -f assets/vcjob-sft.yaml
```

## Step 6: Manage the Task and Troubleshoot

Use the following commands to manage the task:
- View task list: `kubectl get vcjob`
- View task status: `kubectl get vcjob <task-name>`
- View pod status: `kubectl get pod`
- View task logs: `kubectl logs <pod-name>`
- Delete task: `kubectl delete vcjob <task-name>`

### Troubleshooting Common Issues

1. **Pod is not created**:
   - Run `kubectl describe vcjob <task-name>` or `kubectl get podgroups`.
   - Check the Volcano scheduler logs for resource insufficiency or PVC mounting issues.
2. **NFS PVC Mounting Issues**:
   - Ensure `nfs-utils` is installed on all K8s nodes.
   - Ensure the NFS StorageClass has `mountPermissions: "0757"`.
3. **Non-Nvidia GPU Scheduling**:
   - Ensure the vendor GPU driver and Kubernetes device plugin are deployed.
   - Modify the resource requests in the YAML file to request the specific vendor GPU (e.g., `huawei.com/Ascend910: 1`).

## Step 7: Experiment Tracking

If `report_to: mlflow` is set in the LLaMA-Factory configuration, training metrics will be automatically sent to the MLFlow server. View and compare experiments in the Alauda AI MLFlow interface.

## Step 8: Launch Inference Service

Once the fine-tuning task completes and the model is pushed to the repository:
1. Go to the model repository and edit the metadata (Task Type: Text Classification, Framework: Transformers).
2. Click **Publish Inference API** -> **Custom Publishing**.
3. Select the **vLLM** inference runtime and configure resources.
4. Click **Publish** and wait for the service to start.

## Resources

### assets/
- `Containerfile`: Dockerfile for building the training runtime image.
- `vcjob-sft.yaml`: Template for submitting the fine-tuning VolcanoJob task.
