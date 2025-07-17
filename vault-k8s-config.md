Legacy tokens are static and do not expire unless manually rotated. They don’t include audience (aud) claims.

Projected tokens are dynamically issued by the Kubernetes API, short-lived (usually 1h), and automatically rotated.

Bound tokens include audience and expiration claims, improving security by limiting token scope and lifetime.


| Section                             | Parameter                             | Required | Description                                                                 |
|-------------------------------------|----------------------------------------|----------|-----------------------------------------------------------------------------|
| **Vault Auth Method Config**        | `token_reviewer_jwt`                   | ✅        | JWT used by Vault to authenticate with the Kubernetes TokenReview API.     |
|                                     | `kubernetes_host`                      | ✅        | Kubernetes API server URL.                                                  |
|                                     | `kubernetes_ca_cert`                   | ✅*       | CA cert to verify the Kubernetes API server's TLS cert.                    |
|                                     | `issuer`                               | ❌        | JWT issuer to validate tokens (for OIDC support).                          |
|                                     | `disable_iss_validation`              | ❌        | Disable issuer claim validation if true.                                   |
|                                     | `pem_keys`                             | ❌        | PEM-encoded public keys to verify JWTs (OIDC).                             |
|                                     | `kubernetes_ca_cert_file`              | ❌        | Path to file containing Kubernetes CA cert.                                |
|                                     | `token_reviewer_jwt_file`              | ❌        | Path to file containing `token_reviewer_jwt`.                              |
|                                     | `disable_local_ca_jwt`                 | ❌        | Disable automatic JWT detection from filesystem.                           |
| **Vault Role Configuration**        | `bound_service_account_names`          | ✅        | List of allowed Kubernetes service accounts.                               |
|                                     | `bound_service_account_namespaces`     | ✅        | List of namespaces for the above service accounts.                         |
|                                     | `policies`                             | ✅        | Vault policies to associate with this role.                                |
|                                     | `token_policies`                       | ❌        | Alternate way to specify token policies.                                   |
|                                     | `ttl`                                  | ❌        | Time-to-live for the Vault token.                                          |
|                                     | `max_ttl`                              | ❌        | Maximum time-to-live for the token.                                        |
|                                     | `period`                               | ❌        | Issue a periodic token instead of normal token.                            |
|                                     | `audience`                             | ❌        | Expected audience (`aud`) in the JWT.                                      |
|                                     | `alias_name_source`                    | ❌        | Use `serviceaccount_uid` or `serviceaccount_name` as entity alias source.  |
|                                     | `token_type`                           | ❌        | Token type to issue: `default`, `batch`, or `service`.                     |
| **Kubernetes Cluster Requirements** | Vault Service Account                  | ✅        | Vault SA with access to call TokenReview API.                              |
|                                     | Vault SA RBAC                          | ✅        | Bind Vault SA to `system:auth-delegator` ClusterRole.                      |
|                                     | Application Service Account            | ✅        | SA used by your app for Vault login.                                       |
|                                     | JWT Token Mount                        | ✅        | Kubernetes mounts SA token into pod (usually automatic).                   |
