#!/bin/bash

set -euo pipefail

# === Interactive Configuration ===
echo "🔧 Vault + OpenShift Kubernetes Auth Setup (using Vault CLI)"

read -p "Enter OpenShift namespace [vault-demo]: " input
NAMESPACE=${input:-vault-demo}

read -p "Enter service account name [vault-auth]: " input
SERVICE_ACCOUNT=${input:-vault-auth}

read -p "Enter Vault policy name [app-policy]: " input
VAULT_POLICY_NAME=${input:-app-policy}

read -p "Enter Vault role name [my-app-role]: " input
VAULT_ROLE_NAME=${input:-my-app-role}

read -p "Enter Vault secret path [secret/data/app/config]: " input
SECRET_PATH=${input:-secret/data/app/config}

read -p "Enter Vault address [https://vault.example.com]: " input
VAULT_ADDR=${input:-https://vault.example.com}

export VAULT_ADDR

vault status >/dev/null || { echo "❌ Vault CLI not authenticated. Run 'vault login' first."; exit 1; }

# === Create Namespace ===
echo "📁 Creating namespace: $NAMESPACE"
oc new-project $NAMESPACE || echo "⚠️  Namespace may already exist"

# === Create Service Account ===
echo "👤 Creating service account: $SERVICE_ACCOUNT"
oc create sa $SERVICE_ACCOUNT -n $NAMESPACE || echo "⚠️  Service account may already exist"

# === Grant Token Reviewer Permissions ===
echo "🔐 Granting token reviewer permissions"
oc adm policy add-cluster-role-to-user system:auth-delegator -z $SERVICE_ACCOUNT -n $NAMESPACE

# === Get SA Token, CA Cert, and API Server ===
SECRET_NAME=$(oc get sa $SERVICE_ACCOUNT -n $NAMESPACE -o jsonpath="{.secrets[0].name}")
SA_JWT_TOKEN=$(oc get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.token}" | base64 -d)
SA_CA_CRT=$(oc get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data['ca\.crt']}" | base64 -d)
K8S_HOST=$(oc whoami --show-server)

# === Enable Kubernetes Auth Method ===
echo "🔑 Enabling Kubernetes auth method in Vault"
vault auth enable kubernetes || echo "⚠️  Kubernetes auth method may already be enabled"

# === Create Vault Policy ===
echo "📜 Writing Vault policy: $VAULT_POLICY_NAME"
cat <<EOF > app-policy.hcl
path "$SECRET_PATH" {
  capabilities = ["read"]
}
EOF

vault policy write "$VAULT_POLICY_NAME" app-policy.hcl

# === Configure Kubernetes Auth Backend ===
echo "🔧 Configuring Kubernetes auth backend"
vault write auth/kubernetes/config \
    token_reviewer_jwt="$SA_JWT_TOKEN" \
    kubernetes_host="$K8S_HOST" \
    kubernetes_ca_cert="$SA_CA_CRT"

# === Create Vault Role ===
echo "🎭 Creating Vault role: $VAULT_ROLE_NAME"
vault write auth/kubernetes/role/$VAULT_ROLE_NAME \
    bound_service_account_names="$SERVICE_ACCOUNT" \
    bound_service_account_namespaces="$NAMESPACE" \
    policies="$VAULT_POLICY_NAME" \
    ttl="1h"

echo
echo "✅ Vault Kubernetes Auth is configured!"
echo "➡️  Use this role in your pod annotations: vault.hashicorp.com/role: \"$VAULT_ROLE_NAME\""
