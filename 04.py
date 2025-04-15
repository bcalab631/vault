import requests

# Vault config
vault_addr = "http://127.0.0.1:8200"
vault_token = "hvs.xxxx"
mount = "secret"  # KV v2 mount point
start_path = "test/"  # Path under /v1/secret/metadata/

headers = {
    "X-Vault-Token": vault_token
}

def list_kv2_secrets(path):
    url = f"{vault_addr}/v1/{mount}/metadata/{path}?list=true"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        keys = response.json()['data']['keys']
        for key in keys:
            full_path = f"{path}{key}"
            if key.endswith('/'):
                print(f"📁 {full_path}")
                list_kv2_secrets(full_path)  # Recursively go deeper
            else:
                print(f"🔑 {full_path}")
    else:
        print(f"❌ Could not list {path}: {response.status_code} - {response.text}")

# Start from 'test/'
list_kv2_secrets("test/")
