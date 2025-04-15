import requests

vault_addr = "http://127.0.0.1:8200"
vault_token = "s.yourVaultTokenHere"
base_path = "secret"  # Change if your mount is different, e.g., 'kv'

headers = {
    "X-Vault-Token": "hvs.xxxxxx"
}

def list_kv2_secrets(path):
    """
    Recursively lists all secrets and subpaths under a given KV v2 path.
    """
    url = f"{vault_addr}/v1/{base_path}/metadata/{path}?list=true"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        keys = response.json()['data']['keys']
        for key in keys:
            full_path = f"{path}{key}"
            if key.endswith('/'):
                print(f"📁 {full_path}")
                list_kv2_secrets(full_path)  # Recurse into subpath
            else:
                print(f"🔑 {full_path}")
    else:
        print(f"Failed to list {path}: {response.status_code} {response.text}")

# Start at the root
list_kv2_secrets("")
