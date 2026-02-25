---
name: manage-inference-service-cli
description: This skill should be used when users want to create, manage, test, or troubleshoot KServe InferenceServices using the CLI. It provides workflows for deploying models (like Qwen2.5) via vLLM, checking their status, testing the OpenAI-compatible API, and troubleshooting common deployment issues.
---

# Manage Inference Service CLI

## Overview

This skill enables you to create, manage, test, and troubleshoot KServe `InferenceService` resources using the command line. It is based on the standard procedures for deploying models (such as Qwen2.5) using vLLM on a Kubernetes cluster with KServe installed.

## Workflow: Creating an Inference Service

To create an InferenceService, follow these steps:

1. **Prepare the YAML**: Use the provided template in `assets/qwen-2-vllm.yaml` as a base. You can modify the `name`, `namespace`, `storageUri`, and `resources` as needed based on the user's request.
2. **Apply the YAML**: Run the following command to apply the configuration to the cluster:
   ```bash
   kubectl apply -f <path-to-yaml> -n <namespace>
   ```
3. **Verify Creation**: Check if the resource was created successfully:
   ```bash
   kubectl get inferenceservice <name> -n <namespace>
   ```

## Workflow: Checking Status and Troubleshooting

To check the status of an InferenceService or troubleshoot issues:

1. **Check the READY status**:
   ```bash
   kubectl get inferenceservice <name> -n <namespace>
   ```
   Wait until the `READY` column shows `True`.

2. **Troubleshoot Pending/Failing Services**:
   If the service is not ready, check the pod logs and events:
   ```bash
   # Get the pods for the InferenceService
   kubectl get pods -n <namespace> -l serving.kserve.io/inferenceservice=<name>
   
   # Check the logs of the predictor container
   kubectl logs -n <namespace> -l serving.kserve.io/inferenceservice=<name> -c kserve-container
   
   # Describe the InferenceService for events
   kubectl describe inferenceservice <name> -n <namespace>
   ```

3. **Common Issues to Look For in Logs**:
   - **GPU Count**: The startup script checks `torch.cuda.device_count()`. If it outputs "No GPUs found", ensure the container has acquired GPU devices (check resource limits/requests).
   - **Model Path**: The script looks for the model in `/mnt/models/${MODEL_NAME}` or `/mnt/models`. If neither exists or the model failed to download, the storage initializer might have failed.
   - **GGUF Models**: If using GGUF models, vLLM only supports single-file GGUF models. The script will exit with an error if multiple `.gguf` files are found.

## Workflow: Testing the Inference Service

Once the InferenceService is `READY` (`True`), you can test it using the OpenAI-compatible API.

1. **Get the Service URL**:
   ```bash
   SERVICE_URL=$(kubectl get inferenceservice <name> -n <namespace> -o jsonpath='{.status.url}')
   echo $SERVICE_URL
   ```

2. **Send a Test Request**:
   Use `curl` to send a request to the `/v1/chat/completions` endpoint. Ensure the `model` parameter matches the `--served-model-name` configured in the InferenceService (usually `<name>` or `<namespace>/<name>`).
   
   ```bash
   curl -X POST ${SERVICE_URL}/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "<name>",
       "messages": [
         {"role": "system", "content": "You are a helpful assistant."},
         {"role": "user", "content": "What is Kubernetes?"}
       ],
       "max_tokens": 50,
       "temperature": 0.7
     }'
   ```

## Resources

### assets/
- `qwen-2-vllm.yaml`: A complete, working example of an InferenceService YAML for deploying Qwen2.5-0.5B-Instruct using vLLM. Use this as a template when generating configurations for users.
