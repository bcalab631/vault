Auth Request:

The client sends a request to an auth endpoint (e.g., /auth/approle/login, /auth/kubernetes/login) with credentials.

Verification:

Vault verifies the credentials against the configured auth method.

Token Issuance:

If successful, Vault returns a client token.

This token is associated with one or more policies that determine what the client can do.

Token Usage:

The client uses the token to access secrets or invoke other Vault operations.

Authentication

A client (app, user, etc.) authenticates to Vault using an auth method (e.g., AppRole, Kubernetes, LDAP).

Vault returns a token tied to the client's identity.

2. Authorization

The token is linked to Vault policies that define what the client can do.

The policy must allow access to venafi/issue/<role> to request certificates.

3. Certificate Issuance

The client uses the token to call the venafi/issue/<role> endpoint, passing a common_name and other cert options.

Vault sends the request to Venafi (TPP or VaaS), which signs and returns the certificate.

Vault returns the certificate, private key, and CA chain to the client.
