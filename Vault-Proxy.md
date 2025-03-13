# Configuring HashiCorp Vault Proxy with Static Secret Caching

This document outlines the steps to configure HashiCorp Vault's proxy with static secret caching, improving performance and reducing load on the Vault server.

## 1. Enable the Vault Proxy

* **Configuration File (`vault.hcl`):**
    * Modify your Vault server's configuration file to enable the proxy.
    * Add a `proxy` block:

    ```hcl
    proxy "tcp" {
      address         = "127.0.0.1:8201" # Or your desired address and port
      cluster_address = "127.0.0.1:8200" # Vault server's address
    }
    ```

    * `address`: The address the proxy will listen on.
    * `cluster_address`: The address of your Vault server.
* **Restart Vault:**
    * Restart your Vault server for the changes to take effect.

## 2. Configure Static Secret Caching

* **Proxy Configuration (Within the `proxy` block):**
    * Add a `cache` block to enable and configure caching.

    ```hcl
    proxy "tcp" {
      address         = "127.0.0.1:8201"
      cluster_address = "127.0.0.1:8200"
      cache {
        enabled       = true
        max_ttl       = "1h" # Maximum Time-to-Live for cached secrets
        min_ttl       = "30s" # Minimum Time-to-Live for cached secrets
        backend_types = ["kv"] # Specify which backend types to cache.
      }
    }
    ```

    * `enabled = true`: Enables caching.
    * `max_ttl`: The maximum duration a cached secret is considered valid.
    * `min_ttl`: The minimum duration a cached secret is considered valid. Vault will not refresh the cache before this time has passed.
    * `backend_types`: Specifies the secret backend types to cache. Common types include `kv` (Key/Value), `aws`, `database`, etc.
* **Fine-tuning Caching:**
    * You can further refine caching behavior by specifying paths or namespaces:

    ```hcl
    cache {
      enabled       = true
      max_ttl       = "1h"
      min_ttl       = "30s"
      backend_types = ["kv"]
      paths         = ["secret/data/my-app/*"] # Cache only secrets under this path.
      # namespaces = ["my-namespace"] # Cache only secrets within this namespace.
    }
    ```

## 3. Authentication

* **Client Authentication:**
    * Clients connecting to the Vault proxy must still authenticate using the same methods as with the Vault server (e.g., tokens, AppRole, Kubernetes).
    * The proxy forwards authentication requests to the Vault server.
    * The client sends its authentication information to the proxy's listening port (e.g., 8201).
* **Token Considerations:**
    * Tokens used for authentication should have appropriate policies that grant access to the secrets being cached.
    * Consider the TTL of the auth token.
* **TLS (Recommended):**
    * Enable TLS for both the Vault server and the proxy to encrypt communication.
    * Configure TLS certificates and keys in the Vault configuration file.

## 4. Client Connection

* **Update Client Configuration:**
    * Modify your client applications or tools to connect to the Vault proxy's address and port (e.g., `127.0.0.1:8201`).
    * Ensure that the client uses the same authentication method as before.

## 5. Monitoring and Logging

* **Vault Logs:**
    * Monitor Vault server logs for caching-related messages and errors.
    * Vault will log information regarding cache hits, misses, and refreshes.
* **Metrics:**
    * Vault exposes metrics that can be used to monitor cache performance.

## Example `vault.hcl` Configuration

```hcl
storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true # Disable TLS for testing, enable in production
}

proxy "tcp" {
  address         = "127.0.0.1:8201"
  cluster_address = "127.0.0.1:8200"
  cache {
    enabled       = true
    max_ttl       = "1h"
    min_ttl       = "30s"
    backend_types = ["kv"]
    paths         = ["secret/data/*"]
  }
}

api_addr = "[http://127.0.0.1:8200](http://127.0.0.1:8200)"
cluster_addr = "[https://127.0.0.1:8201](https://127.0.0.1:8201)"
disable_mlock = true
