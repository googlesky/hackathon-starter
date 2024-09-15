#!/bin/bash

# Paths to the files
VALUES_FILE="values.yaml"
CONFIG_FILE="config.yaml"
ENV_FILE=$(grep "^app_config" $(CONFIG_FILE) | head -n 1 | awk '{print $2}')
CHART_PATH="./chart"

# Check if config.yaml exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE not found!"
  exit 1
fi

# Check if values.yaml exists
if [ ! -f "$VALUES_FILE" ]; then
  echo "Error: $VALUES_FILE not found!"
  exit 1
fi

# Check if the chart directory exists
if [ ! -d "$CHART_PATH" ]; then
  echo "Error: Helm chart directory $CHART_PATH not found!"
  exit 1
fi

# Check if .env exists and base64 encode it
if [ -f "$ENV_FILE" ]; then
  app_config=$(base64 -w 0 "$ENV_FILE")
else
  echo "Warning: .env file not found! Skipping app_config replacement."
fi

# Function to replace placeholders in values.yaml
replace_placeholder() {
  local key="$1"
  local value="$2"
  # Escape special characters in value for sed
  escaped_value=$(echo "$value" | sed 's/[&/\]/\\&/g')
  sed -i "s|{$key}|$escaped_value|g" "$VALUES_FILE"
}

replace_images_tag_by_commit() {
  # Get the latest commit SHA from the git repository
  commit_sha=$(git rev-parse HEAD)
  if [ -z "$commit_sha" ]; then
    echo "Error: Unable to retrieve commit SHA!"
    exit 1
  fi

  sed -i "s|{commit_sha}|$commit_sha|g" "$VALUES_FILE"
}

# Initialize variables for kubernetes_namespace and environment
kubernetes_namespace=""
environment=""

replace_images_tag_by_commit

# Read key-value pairs from config.yaml
while IFS=: read -r key value; do
  # Remove leading/trailing whitespace
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  
  # If the key or value is empty, skip
  if [ -z "$key" ] || [ -z "$value" ]; then
    continue
  fi
  
  # Store kubernetes_namespace and environment for later use
  if [ "$key" == "kubernetes_namespace" ]; then
    kubernetes_namespace="$value"
  elif [ "$key" == "environment" ]; then
    environment="$value"
  fi

  # Replace placeholder in values.yaml
  if grep -q "{$key}" "$VALUES_FILE"; then
    replace_placeholder "$key" "$value"
  else
    echo "Warning: Placeholder for {$key} not found in $VALUES_FILE."
  fi
done < "$CONFIG_FILE"

# Replace app_config placeholder if .env was found and encoded
if [ -n "$app_config" ]; then
  if grep -q "{app_config}" "$VALUES_FILE"; then
    replace_placeholder "app_config" "$app_config"
  else
    echo "Warning: Placeholder for {app_config} not found in $VALUES_FILE."
  fi
fi

# Ensure both kubernetes_namespace and environment have been set
if [ -z "$kubernetes_namespace" ] || [ -z "$environment" ]; then
  echo "Error: kubernetes_namespace or environment not set in config.yaml!"
  exit 1
fi

# Create the namespace if it doesn't exist
namespace="${kubernetes_namespace}-${environment}"
kubectl get namespace "$namespace" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating Kubernetes namespace: $namespace"
  kubectl create namespace "$namespace"
fi

# Run Helm deploy
echo "Deploying Helm chart to namespace: $namespace"
helm upgrade --install \
  "$kubernetes_namespace" \
  "$CHART_PATH" \
  -n "$namespace" \
  -f "$VALUES_FILE"

echo "Helm deployment completed successfully."