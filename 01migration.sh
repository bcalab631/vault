#!/bin/bash

# --- Config ---
SRC_VAULT_ADDR="http://127.0.0.1:8500"
SRC_VAULT_TOKEN=""

DEST_VAULT_ADDR="http://127.0.0.1:8600"
DEST_VAULT_TOKEN=""

KV_PATH="secret"  # KVv2 mount path (same on both Vaults)
DRY_RUN=false    # Set to true for dry run (no writing)

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Function: Recursive copy ---
copy_secrets_recursive() {
    local path="$1"

    # List keys (directories or secrets) at this path
    local keys
    keys=$(VAULT_ADDR=$SRC_VAULT_ADDR VAULT_TOKEN=$SRC_VAULT_TOKEN vault kv list -format=json "${KV_PATH}/${path}" 2>/dev/null | jq -r '.[]')

    if [[ -z "$keys" ]]; then
        echo -e "${YELLOW}⚠️  No keys found at ${KV_PATH}/${path}${NC}"
        return
    fi

    for key in $keys; do
        clean_key=$(echo "$key" | tr -d '\r')

        if [[ "$clean_key" == */ ]]; then
            # Directory — recurse into it
            copy_secrets_recursive "${path}${clean_key}"
        else
            # Secret — copy it
            full_path="${path}${clean_key}"
            echo -e "${GREEN}📄 Copying secret: ${KV_PATH}/${full_path}${NC}"

            # Read secret data from source
            secret_json=$(VAULT_ADDR=$SRC_VAULT_ADDR VAULT_TOKEN=$SRC_VAULT_TOKEN \
                vault kv get -format=json "${KV_PATH}/${full_path}" 2>/dev/null)

            if [[ -z "$secret_json" ]]; then
                echo -e "${RED}❌ Failed to read secret at ${KV_PATH}/${full_path}${NC}"
                continue
            fi

            # Extract secret data (KVv2 format: data.data)
            data=$(echo "$secret_json" | jq -c '.data.data')

            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${YELLOW}[DRY RUN] Would copy: ${KV_PATH}/${full_path}${NC}"
            else
                # Write to destination using stdin JSON (safe for special chars)
                echo "$data" | VAULT_ADDR=$DEST_VAULT_ADDR VAULT_TOKEN=$DEST_VAULT_TOKEN \
                    vault kv put "${KV_PATH}/${full_path}" - >/dev/null

                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}✅ Copied: ${KV_PATH}/${full_path}${NC}"
                else
                    echo -e "${RED}❌ Failed to write secret at ${KV_PATH}/${full_path}${NC}"
                fi
            fi
        fi
    done
}

# --- Start ---
echo -e "${YELLOW}🔍 Scanning and copying secrets from ${SRC_VAULT_ADDR} to ${DEST_VAULT_ADDR}...${NC}"
echo -e "${YELLOW}🔐 KV Path: ${KV_PATH}/ (KVv2)${NC}"
$DRY_RUN && echo -e "${YELLOW}🚧 DRY RUN MODE ENABLED — no changes will be made.${NC}"

copy_secrets_recursive ""

echo -e "${GREEN}🎉 Secret copy process complete.${NC}"
