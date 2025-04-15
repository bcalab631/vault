from flask import Flask, render_template, request, jsonify
import requests

app = Flask(__name__)

# Define Vault's URL (adjust as needed)
VAULT_URL = "http://127.0.0.1:8200"  # Replace with your Vault server address

# Route to display the UI
@app.route('/')
def index():
    return render_template('index.html')

# Route to handle the request for listing secrets
@app.route('/list_secrets', methods=['POST'])
def list_secrets():
    token = request.form['token']
    secret_path = request.form['secret_path']
    
    # Define the Vault API endpoint for listing secrets at the given path
    headers = {
        'X-Vault-Token': token
    }
    
    url = f"{VAULT_URL}/v1/{secret_path}"
    
    # Make a request to Vault to retrieve the secrets
    response = requests.get(url, headers=headers)
    
    print(f"List Secrets Response: {response.status_code} - {response.text}")  # Debugging line
    
    if response.status_code == 200:
        secrets = response.json()
        return render_template('index.html', secrets=secrets['data'], token=token, secret_path=secret_path)
    else:
        error_message = response.json().get('errors', ['Unknown error'])
        return render_template('index.html', error=error_message[0], token=token, secret_path=secret_path)

# Route to handle the request for patching (updating) secrets
@app.route('/patch_secret', methods=['POST'])
def patch_secret():
    token = request.form['token']
    secret_path = request.form['secret_path']
    secret_key = request.form['secret_key']
    new_value = request.form['new_value']
    
    # Prepare the payload to update the secret
    headers = {
        'X-Vault-Token': token,
        'Content-Type': 'application/merge-patch+json'  # Correct Content-Type for PATCH
    }
    
    # Define the Vault API endpoint for patching the secret
    url = f"{VAULT_URL}/v1/{secret_path}"
    payload = {
        "data": {
            secret_key: new_value
        }
    }
    
    # Make the PATCH request to Vault to update the secret
    response = requests.patch(url, headers=headers, json=payload)
    
    # Debugging: Log the response content and status code
    print(f"Patch Secret Response: {response.status_code} - {response.text}")
    
    if response.status_code == 200:
        success_message = "Secret updated successfully!"
        # List the updated secrets after the patch
        return render_template('index.html', success=success_message, token=token, secret_path=secret_path)
    else:
        error_message = response.json().get('errors', ['Unknown error'])
        return render_template('index.html', error=error_message[0], token=token, secret_path=secret_path)

if __name__ == '__main__':
    app.run(debug=True)
