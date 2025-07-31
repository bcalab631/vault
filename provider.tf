#role_id    export TF_VAR_vault_role_id="7264c111-7d75-43c0-2b93-1f7a2204c03d"
#secret_id  export TF_VAR_vault_secret_id="404471fb-6ff3-f49c-9673-15d3c388b345"
#role_id    7264c111-7d75-43c0-2b93-1f7a2204c03d
#secret_id             075e2df1-7ca1-5b15-9337-0b99e4c81cea

variable "vault_role_id" {
  description = "Vault AppRole Role ID"
  type        = string
}

variable "vault_secret_id" {
  description = "Vault AppRole Secret ID"
  type        = string
  sensitive   = true
}
provider "vault" {
    address = "http://127.0.0.1:8200"
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

resource "vault_mount" "kv" {
  path        = "secret1"         # This is the mount path (e.g., secret/, kv/, etc.)
  type        = "kv"
  description = "Key/Value secrets engine"

  options = {
    version = "2"                # Use KV v2 (most common)
  }
}


resource "vault_mount" "kv2" {
  path        = "secret2"         # This is the mount path (e.g., secret/, kv/, etc.)
  type        = "kv"
  description = "Key/Value secrets engine"

  options = {
    version = "2"                # Use KV v2 (most common)
  }
}
