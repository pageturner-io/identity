# Identity

## Deploying the application

1. Create the secret files:
- deploy/secrets/github_client_id
- deploy/secrets/github_client_secret
- deploy/secrets/guardian_secret_key
- deploy/secrets/secret_key_base

2. Deploy the Docker stack
```bash
docker-pageturner deploy --compose-file deploy/docker-compose.yml identity
```
