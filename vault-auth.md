Auth Request:

The client sends a request to an auth endpoint (e.g., /auth/approle/login, /auth/kubernetes/login) with credentials.

Verification:

Vault verifies the credentials against the configured auth method.

Token Issuance:

If successful, Vault returns a client token.

This token is associated with one or more policies that determine what the client can do.

Token Usage:

The client uses the token to access secrets or invoke other Vault operations.
