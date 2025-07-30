data "external" "jwt" {
  program = ["sh", "-c", <<EOT
echo '{ "jwt": "'"$TFE_JOB_JWT"'" }'
EOT
  ]
}

output "tfe_job_jwt" {
  value = data.external.jwt.result["jwt"]
  sensitive = true
}
