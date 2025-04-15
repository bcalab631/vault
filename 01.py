from flask import Flask, render_template, request
import hvac

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    secrets = None
    error = None

    if request.method == 'POST':
        # Get the Vault token and secret path from the form
        vault_token = request.form.get('vault_token')
        secret_path = request.form.get('secret_path')

        # Initialize the Vault client with the provided token
        try:
            # Create a Vault client with the provided token
            client = hvac.Client(url="http://127.0.0.1:8200", token=vault_token)

            # Check if the client is authenticated
            if not client.is_authenticated():
                error = "Vault authentication failed. Please check your token."
                return render_template('index.html', secrets=secrets, error=error)

            # Access secrets from the specified path
            secret_response = client.secrets.kv.list_secrets(path=secret_path)
            
            # Check if secrets are returned
            if 'data' in secret_response and 'keys' in secret_response['data']:
                secrets = secret_response['data']['keys']
            else:
                secrets = []  # No secrets found at the path

        except Exception as e:
            error = f"Error accessing Vault: {e}"

    return render_template('index.html', secrets=secrets, error=error)


if __name__ == "__main__":
    app.run(debug=True)
