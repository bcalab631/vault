Vault Kubernetes Authentication Backend: Verify that the Vault Kubernetes authentication method is enabled using vault auth list.

Vault Kubernetes Auth Configuration: Ensure Vault is configured with the correct Kubernetes API URL and CA certificate for token validation.

Kubernetes Service Account Token Authentication: Authenticate using a Kubernetes service account token and verify the successful authentication response from Vault.

Vault Role Bound to Service Account: Ensure a Vault role is correctly bound to a Kubernetes service account and policies are applied.

Vault Policies for Service Account: Verify that the correct Vault policies are assigned to the Kubernetes service account and access is allowed based on policy.

Token Expiration and Renewal: Ensure that Vault issues tokens with correct TTL and supports token renewal before expiration.

Role Bindings for Multiple Service Accounts: Validate that a single Vault role supports multiple service accounts and each can authenticate.

Access Denied for Unauthorized Service Account: Verify that service accounts not bound to the correct role are denied access to Vault.

Authentication with OpenShift Default Service Account: Test authentication using the OpenShift default service account to ensure it is restricted unless explicitly allowed by roles.

OpenShift Vault Secret Access: Confirm that a Kubernetes pod can retrieve Vault secrets when using the appropriate service account with the correct permissions.
