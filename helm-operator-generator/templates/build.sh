#!/bin/bash

export CSV="./bundle/manifests/model-registry-operator.clusterserviceversion.yaml"
export VALUE="./helm-charts/chart-kubeflow-model-registry/values.yaml"
#  CHART_VERSION=1.15  TIMESTAMP=123  ./.alauda/build.sh
#  git diff bundle/manifests/model-registry-operator.clusterserviceversion.yaml
function tweak-in-ci() {
    set -xeo pipefail
    echo "starting model-registry-plugin.sh"
    ls ./
    env
    local acp_chart_version="$1"
    local model_registry_tag="$2"
    local model_registry_mysql_tag="$3"
    local timestamp="$4"

    local registry="build-harbor.alauda.cn"
    local registry_path="mlops"

    if [ -z "$acp_chart_version" ]; then
        echo "acp_chart_version is empty, please set it"
        exit 1
    fi
    if [ -z "$model_registry_tag" ]; then
        echo "model_registry_tag is empty, please set it"
        exit 1
    fi
    if [ -z "$model_registry_mysql_tag" ]; then
        echo "model_registry_mysql_tag is empty, please set it"
        exit 1
    fi
    if [ -z "$timestamp" ]; then
        echo "timestamp is empty, please set it"
        exit 1
    fi

    echo "acp_chart_version $acp_chart_version"
    echo "model_registry_tag $model_registry_tag"
    echo "model_registry_mysql_tag $model_registry_mysql_tag"
    echo "timestamp $timestamp"

    ls ./helm-charts/chart-kubeflow-model-registry/
    cat $VALUE
    echo "update default values"

    yq -i '.global.imageRegistry="build-harbor.alauda.cn"' $VALUE
    yq -i ".global.registry.address=\"build-harbor.alauda.cn\"" $VALUE

    # update .global.images to make violet happy
    yq -i ".global.images.modelRegistryServer.repository=\"mlops/kubeflow/model-registry-server\"" $VALUE
    yq -i ".global.images.modelRegistryServer.pullPolicy=\"IfNotPresent\"" $VALUE
    yq -i ".global.images.modelRegistryServer.tag=\"$model_registry_tag\"" $VALUE
    yq -i ".global.images.modelRegistryServer.support_arm=true" $VALUE

    yq -i ".global.images.mysql.repository=\"mlops/kubeflow/model-registry-mysql\"" $VALUE
    yq -i ".global.images.mysql.tag=\"$model_registry_mysql_tag\"" $VALUE
    yq -i ".global.images.mysql.support_arm=true" $VALUE

    # enable backendapi, ai team need this. but it may unsecure https://gateway.envoyproxy.io/docs/tasks/traffic/backend

    make bundle IMG="$registry/$registry_path/model-registry-operator:v${acp_chart_version}.${timestamp}" CHANNELS=stable
    local images=$(
        cat <<EOF
  - image: ${registry}/${registry_path}/model-registry-operator:v${acp_chart_version}.${timestamp}
    name: model-registry-operator
  - image: ${registry}/${registry_path}/kubeflow/model-registry-server:${model_registry_tag}
    name: model-registry-server
  - image: ${registry}/${registry_path}/kubeflow/model-registry-mysql:${model_registry_mysql_tag}
    name: model-registry-mysql
EOF
    )
    export IMAGES=$images
    yq -i eval ".spec.relatedImages = env(IMAGES)" $CSV
    # csv name
    yq -i eval ".metadata.name = \"model-registry-operator.v${acp_chart_version}-build.${timestamp}\" " $CSV
    yq -i eval ".spec.version = \"${acp_chart_version}-build.${timestamp}\" " $CSV
    # suggest ns
    yq -i eval ".metadata.annotations.\"operatorframework.io/suggested-namespace\" = \"model-registry-operator\"" $CSV
    yq -i eval ".metadata.annotations.\"operatorframework.io/olm.skipRange\" = \">=0.0.0 < ${acp_chart_version}-build.${timestamp}\" " $CSV
    yq -i eval '.metadata.annotations.provider = "{\"zh\":\"Alauda\",\"en\":\"Alauda\"}"' $CSV
    yq -i eval ".metadata.annotations.provider-type = \"platform\"" $CSV
    yq -i eval '.metadata.annotations.categories = "AI"' $CSV
    yq -i eval '.metadata.annotations.description = "Manage kubeflow model registry instances."' $CSV
    # Add architecture and protocol
    yq -i eval '.metadata.labels."operatorframework.io/arch.amd64" = "supported"' $CSV
    yq -i eval '.metadata.labels."operatorframework.io/arch.arm64" = "supported"' $CSV
    yq -i eval '.metadata.labels."cpaas.io/protocol.stack.ipv4" = "supported"' $CSV
    yq -i eval '.metadata.labels."cpaas.io/protocol.stack.ipv6" = "supported"' $CSV

    yq -i eval '.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.requests.cpu = "500m"' $CSV
    yq -i eval '.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.requests.memory = "512Mi"' $CSV
    yq -i eval '.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.limits.cpu = "4"' $CSV
    yq -i eval '.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.limits.memory = "2Gi"' $CSV


    tweak-ui

    git status
    git diff | cat
    ls
    helm template -f $VALUE ./helm-charts/chart-kubeflow-model-registry | grep image
}

function tweak-ui() {
    local ui=$(
        cat <<EOF
      - displayName: mysqlStorageClass
        path: global.mysqlStorageClass
        x-descriptors:
          - urn:alm:descriptor:com.tectonic.ui:text
          - urn:alm:descriptor:com.tectonic.ui:resourceRequirements:required
          - urn:alm:descriptor:label:en:Mysql Storage Class
          - urn:alm:descriptor:label:zh:Mysql 存储类
          - urn:alm:descriptor:com.tectonic.default:standard
      - displayName: mysqlStorageSize
        path: global.mysqlStorageSize
        x-descriptors:
          - urn:alm:descriptor:com.tectonic.ui:text
          - urn:alm:descriptor:com.tectonic.ui:resourceRequirements:required
          - urn:alm:descriptor:label:en:Mysql Storage Size
          - urn:alm:descriptor:label:zh:Mysql 存储大小
          - urn:alm:descriptor:com.tectonic.default:10Gi
      - displayName: modelRegistryDisplayName
        path: global.modelRegistryDisplayName
        x-descriptors:
          - urn:alm:descriptor:com.tectonic.ui:text
          - urn:alm:descriptor:com.tectonic.ui:resourceRequirements:required
          - 'urn:alm:descriptor:com.tectonic.default:Kubeflow Model Registry'
          - urn:alm:descriptor:label:en:Model Registry Display Name
          - urn:alm:descriptor:label:zh:模型注册表显示名称
          - urn:alm:descriptor:tooltip:en:Model Registry Display Name
          - urn:alm:descriptor:tooltip:zh:模型注册表显示名称
      - displayName: modelRegistryDescription
        path: global.modelRegistryDescription
        x-descriptors:
          - urn:alm:descriptor:com.tectonic.ui:text
          - 'urn:alm:descriptor:com.tectonic.default:An example model registry'
          - urn:alm:descriptor:label:en:Model Registry Description
          - urn:alm:descriptor:label:zh:模型注册表描述
          - urn:alm:descriptor:tooltip:en:Model Registry Description
          - urn:alm:descriptor:tooltip:zh:模型注册表描述
EOF
    )
    export UI=$ui

    yq -i '
  with(.spec.customresourcedefinitions.owned[] | select(.kind == "ModelRegistry"); .specDescriptors = env(UI))
' $CSV
}

# Get gateway and ratelimit from renovate, proxy version from gateway image label
function pick-image-version {
    local model_registry_server_tag=$(yq -r '.global.images.modelRegistryServer.tag' $VALUE)
    local model_registry_mysql_tag=$(yq -r '.global.images.mysql.tag' $VALUE)
    
    echo "$model_registry_server_tag $model_registry_mysql_tag"
}

# verify all three images exist in registry
function verify-images-exist {
    local model_registry_server_image=$1
    local model_registry_mysql_image=$2

    local registry="registry.alauda.cn:60070"

    echo "Verifying images exist..."
    
    for image in "$model_registry_server_image" "$model_registry_mysql_image"; do
        echo "Checking: $image"
        if ! skopeo inspect --tls-verify=false "docker://$registry/$image" > /dev/null 2>&1; then
            echo "Error: Image not found: $registry/$image"
            exit 1
        fi
        echo "  OK"
    done
    
    echo "All images verified successfully!"
}

# verify renovate.json5 is in sync with template
function verify-renovate-config {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root=$(dirname "$script_dir")
    local temp_file=$(mktemp)
    
    echo "Verifying renovate.json5 is in sync with template..."
    
    # Generate expected config using generate-renovate-config.sh
    bash "$script_dir/generate-renovate-config.sh" "$temp_file" > /dev/null 2>&1
    
    # Compare with existing renovate.json5 in git repo
    if ! diff -q "$repo_root/renovate.json5" "$temp_file" > /dev/null 2>&1; then
        echo "Error: renovate.json5 is out of sync with template!"
        echo "Please run: ./.alauda/generate-renovate-config.sh"
        rm -f "$temp_file"
        exit 1
    fi
    
    rm -f "$temp_file"
    echo "renovate.json5 is in sync with template."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cd model-registry-operator

    ls $VALUE
    cat $VALUE
    echo "yq modelRegistryServer: "
    yq '.global.images.modelRegistryServer.tag' $VALUE

    images=$(pick-image-version)
    MODEL_REGISTRY_VERSION=$(echo $images | awk '{print $1}')
    MODEL_REGISTRY_MYSQL_VERSION=$(echo $images | awk '{print $2}')

    echo "images: ${images}"
    echo "MODEL_REGISTRY_VERSION: ${MODEL_REGISTRY_VERSION}"
    echo "MODEL_REGISTRY_MYSQL_VERSION: ${MODEL_REGISTRY_MYSQL_VERSION}"

    if [[ -z "$MODEL_REGISTRY_VERSION" || -z "$MODEL_REGISTRY_MYSQL_VERSION" ]]; then
        echo "Error: Model Registry or MySQL image version not found."
        exit 1
    fi
    if [[ -z "$CHART_VERSION" ]]; then
        echo "Error: Chart version not found."
        exit 1
    fi
    if [[ -z "$TIMESTAMP" ]]; then
        echo "Error: Timestamp not found."
        exit 1
    fi

    # Verify renovate.json5 is in sync with template
    # verify-renovate-config

    # Verify all dependent images exist
    verify-images-exist \
        "mlops/kubeflow/model-registry-server:$MODEL_REGISTRY_VERSION" \
        "mlops/kubeflow/model-registry-mysql:$MODEL_REGISTRY_MYSQL_VERSION"
    tweak-in-ci $CHART_VERSION $MODEL_REGISTRY_VERSION $MODEL_REGISTRY_MYSQL_VERSION $TIMESTAMP
fi
