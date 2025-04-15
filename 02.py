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
    
    if response.status_code == 200:
        secrets = response.json()
        return render_template('index.html', secrets=secrets['data'], token=token, secret_path=secret_path)
    else:
        error_message = response.json().get('errors', ['Unknown error'])
        return render_template('index.html', error=error_message[0], token=token, secret_path=secret_path)

if __name__ == '__main__':
    app.run(debug=True)
