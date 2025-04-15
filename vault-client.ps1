# Define Vault addresses for different environments
$environments = @{
    "1" = @{ Name = "Development"; Address = "https://vault.dev.company.com" }
    "2" = @{ Name = "Staging";     Address = "https://vault.staging.company.com" }
    "3" = @{ Name = "Production";  Address = "https://vault.company.com" }
}

# Show environment choices
Write-Host "Select Vault Environment:`n"
foreach ($key in $environments.Keys) {
    $env = $environments[$key]
    Write-Host "$key. $($env.Name) ($($env.Address))"
}

$selection = Read-Host "`nEnter the number of the environment"
if (-not $environments.ContainsKey($selection)) {
    Write-Host "Invalid selection. Exiting..." -ForegroundColor Red
    exit
}

$chosenEnv = $environments[$selection]

# Prompt for Vault token
$vaultToken = Read-Host "Enter the Vault token"

# Query Vault for namespaces
$headers = @{ "X-Vault-Token" = $vaultToken }
$namespaceUrl = "$($chosenEnv.Address)/v1/sys/namespaces"

try {
    $response = Invoke-RestMethod -Uri $namespaceUrl -Method GET -Headers $headers
    $namespaces = $response.data.keys

    if (-not $namespaces) {
        Write-Host "No namespaces found or insufficient permission." -ForegroundColor Yellow
        $vaultNamespace = Read-Host "Enter the Vault namespace manually (or leave blank)"
    } else {
        Write-Host "`nAvailable Namespaces:"
        for ($i = 0; $i -lt $namespaces.Count; $i++) {
            Write-Host "$($i + 1). $($namespaces[$i])"
        }

        $nsChoice = Read-Host "`nChoose a namespace by number"
        if ($nsChoice -match '^\d+$' -and $nsChoice -ge 1 -and $nsChoice -le $namespaces.Count) {
            $vaultNamespace = $namespaces[$nsChoice - 1]
        } else {
            Write-Host "Invalid selection. Setting namespace as empty." -ForegroundColor Yellow
            $vaultNamespace = ""
        }
    }
} catch {
    Write-Host "Error retrieving namespaces: $_" -ForegroundColor Red
    $vaultNamespace = Read-Host "Enter the Vault namespace manually (or leave blank)"
}

# Set environment variables
[System.Environment]::SetEnvironmentVariable("VAULT_ADDR", $chosenEnv.Address, "Process")
[System.Environment]::SetEnvironmentVariable("VAULT_NAMESPACE", $vaultNamespace, "Process")
[System.Environment]::SetEnvironmentVariable("VAULT_TOKEN", $vaultToken, "Process")

# Confirm
Write-Host "`nVault environment variables set for current session:"
Write-Host "VAULT_ADDR      = $($chosenEnv.Address)"
Write-Host "VAULT_NAMESPACE = $vaultNamespace"
Write-Host "VAULT_TOKEN     = $vaultToken"
