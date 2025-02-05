
Use Case	Objective	Description	Expected Outcome
1. Secure Retrieval of Static Secrets Using Vault CSI	Validate that OpenShift applications can securely retrieve static secrets via Vault CSI.	- Static secrets (e.g., API keys, static passwords) are stored in Vault.
- OpenShift application mounts these secrets as volumes using Vault CSI.	- Static secrets are retrieved from Vault and mounted securely into the OpenShift pod.
- No secrets are stored in ETCD, and access is controlled by Vault policies.
2. Secure Retrieval of Dynamic Secrets Using Vault CSI	Ensure that OpenShift applications can securely retrieve dynamic secrets (e.g., database credentials, tokens) from Vault via Vault CSI.	- OpenShift application requests a dynamic secret (e.g., database credentials) from Vault.
- Vault generates the secret dynamically based on policies and mounts it into the pod via Vault CSI.	- Dynamic secrets are retrieved securely from Vault.
- Secrets are time-limited and auto-rotated as per Vault's dynamic secrets policies.
3. Automatic Secret Update for Static Secrets via Vault CSI	Ensure that static secrets retrieved by Vault CSI are automatically updated when they are rotated in Vault.	- Static secrets are stored in Vault and retrieved by OpenShift pods using Vault CSI.
- Vault CSI detects secret changes in Vault and automatically updates the mounted volume with the new version.	- Static secrets are updated automatically in OpenShift pods when Vault rotates them.
- Secrets are always up-to-date without needing to store them in ETCD.
4. Automatic Secret Update for Dynamic Secrets via Vault CSI	Ensure that dynamic secrets retrieved by Vault CSI are automatically refreshed when the secrets are rotated or expired.	- OpenShift pods access dynamic secrets like database credentials through Vault CSI.
- Vault CSI periodically checks Vault for secret expiration or updates.
- When secrets expire or are rotated in Vault, the CSI driver automatically updates the volume with the new secrets.	- Dynamic secrets are automatically refreshed and updated when expired or rotated.
- The application is always using valid secrets.
5. Vault Authentication Using Kubernetes Service Account for Static Secrets	Test Kubernetes service account-based authentication for retrieving static secrets using Vault CSI.	- OpenShift application uses a Kubernetes service account token to authenticate with Vault.
- Vault CSI retrieves static secrets using the authenticated service account token.	- Vault securely authenticates using the Kubernetes service account.
- Static secrets are securely mounted into the application’s persistent volume without storing them in ETCD.
6. Vault Authentication Using Kubernetes Service Account for Dynamic Secrets	Test Kubernetes service account-based authentication for retrieving dynamic secrets using Vault CSI.	- OpenShift application authenticates using a Kubernetes service account.
- Vault CSI dynamically retrieves secrets (e.g., database credentials) based on policies for the application.	- Vault CSI retrieves dynamic secrets securely based on policies and the Kubernetes service account.
- Secrets are always up-to-date and not stored in ETCD.
7. Cross-Cluster Migration of Static Secrets via Vault CSI	Ensure that static secrets stored in Vault can be securely accessed across multiple OpenShift clusters.	- Multiple OpenShift clusters (in different regions or environments) use Vault CSI to access the same Vault instance for static secrets.
- Static secrets are mounted into each OpenShift pod’s volume in different clusters.	- Static secrets are securely shared across multiple clusters using Vault CSI.
- No secrets are replicated or stored in ETCD on individual clusters.
8. Cross-Cluster Migration of Dynamic Secrets via Vault CSI	Test the secure access of dynamic secrets across multiple OpenShift clusters using Vault CSI.	- Multiple OpenShift clusters use Vault CSI to access dynamic secrets (e.g., database credentials, tokens) from the same central Vault instance.
- Dynamic secrets are mounted dynamically into each cluster’s pods.	- Dynamic secrets are securely fetched from Vault on demand across clusters.
- No secrets are stored in ETCD and each cluster retrieves the appropriate secrets at runtime.
9. Secret Expiry and Rotation Handling for Static Secrets via Vault CSI	Ensure that static secrets are automatically updated in OpenShift pods when they expire or are rotated.	- Static secrets are fetched from Vault and stored in OpenShift pods via Vault CSI.
- Vault periodically rotates these static secrets.
- Vault CSI updates the mounted volumes when secrets are refreshed.	- Static secrets are updated in OpenShift without storing them in ETCD.
- Applications always have access to the most recent static secrets.
10. Secret Expiry and Rotation Handling for Dynamic Secrets via Vault CSI	Ensure that dynamic secrets (e.g., database credentials) retrieved via Vault CSI are updated automatically when they expire or are rotated.	- Dynamic secrets such as database credentials are retrieved from Vault.
- Vault automatically rotates or expires dynamic secrets.
- Vault CSI updates the volume automatically when new credentials are generated.	- Dynamic secrets are always fresh and valid.
- The OpenShift pod accesses the most up-to-date credentials without storing them in ETCD.
11. Vault CSI for Multi-Tenant Secret Management (Static Secrets)	Test the ability to isolate static secrets for multiple tenants or applications in a multi-tenant OpenShift environment.	- Multiple OpenShift applications (representing different tenants) retrieve static secrets from Vault.
- Each application is authorized to access only its assigned static secrets.	- Static secrets are securely isolated for each tenant using Vault policies.
- Secrets are injected securely via Vault CSI, and no secrets are stored in ETCD.
12. Vault CSI for Multi-Tenant Secret Management (Dynamic Secrets)	Test the ability to securely provide dynamic secrets to multiple OpenShift applications in a multi-tenant environment.	- Multiple OpenShift applications request dynamic secrets (e.g., database credentials) from Vault.
- Vault generates dynamic secrets for each application based on policies and injects them into the pods using Vault CSI.	- Dynamic secrets are securely generated and injected into OpenShift pods for each tenant.
- Vault ensures no secrets are stored in ETCD, and access is controlled by Vault policies.
13. Audit Logging of Secret Access via Vault CSI	Test the ability to log and monitor secret access requests made via Vault CSI.	- Vault audit logging is enabled to capture requests for secret retrieval.
- OpenShift applications access secrets via Vault CSI.
- Vault logs all access to the secrets.	- Audit logs capture every access event, providing visibility into secret retrieval.
- OpenShift applications do not store secrets in ETCD, and all access is securely logged.
14. Disaster Recovery with Secret Access During Vault Failover via Vault CSI	Ensure OpenShift applications can still retrieve secrets after Vault failover.	- Vault is configured with high availability.
- OpenShift applications continue to access their secrets from Vault during failover via Vault CSI.
- The failover process ensures that secrets remain accessible to the pods.	- OpenShift applications continue to retrieve secrets after Vault failover.
- Secrets are securely mounted in the application pods without storing them in ETCD.
Key Points:
Static Secrets: These are fixed secrets like API keys, passwords, or certificates that remain unchanged unless manually updated. OpenShift applications retrieve these secrets from Vault using Vault CSI and mount them into the pods. When Vault updates the static secret (e.g., via rotation), Vault CSI automatically updates the mounted volumes.

Dynamic Secrets: These are secrets generated on-demand, such as database credentials or short-lived API tokens. Vault dynamically generates these secrets, and the Vault CSI driver ensures they are mounted into OpenShift pods. Dynamic secrets are automatically rotated or expire based on defined policies in Vault, and Vault CSI keeps the mounted volumes updated with the latest valid secrets.

Cross-Cluster and Multi-Tenant Access: Both static and dynamic secrets can be accessed securely across multiple OpenShift clusters. Vault CSI ensures that each cluster retrieves its authorized secrets without storing them in ETCD. Multi-tenant secret management is supported by Vault policies that isolate access between tenants.

No ETCD Storage: Vault CSI ensures that secrets are mounted into the OpenShift pods and are never stored in ETCD. This avoids the security risks associated with storing sensitive data in ETCD while ensuring seamless secret management and access.

These use cases demonstrate how Vault CSI can be leveraged to handle both static and dynamic secrets securely in OpenShift while adhering to best practices like secret rotation, multi-cluster/multi-region access, and centralized secret management in HashiCorp Vault.



