# LTT LTC — Cloudflare edge (Terraform) + CI/CD orchestration

This repository defines **Cloudflare-only** infrastructure as code and hosts **split GitHub Actions** workflows that other repos trigger via `repository_dispatch`. Compute, databases, and Tailscale stay **100% on your local hardware**.

## What Terraform manages

| Managed here | Not managed here (local / other tooling) |
|--------------|------------------------------------------|
| Cloudflare DNS for apex / `www` / `api` → Tunnel | Physical servers, OS upgrades |
| Cloudflare Zero Trust **cloudflared** tunnel + public hostname ingress | Tailscale installation & ACLs |
| | K3s / workloads / Helm |
| | SQL Server, MongoDB, Redis, Kafka |

Public hostnames match the application compose stack (`deploy/docker-compose.yml` in the LTT repo): **`ltt-ltc.io.vn`**, **`www.ltt-ltc.io.vn`**, **`api.ltt-ltc.io.vn`**. Ingress targets default to **`http://ltt-ltc-nginx:80`** (Compose service name). When you move to Kubernetes, update `origin_web_url` / `origin_api_url` to your in-cluster Ingress or Service DNS name.

## Layout

```text
modules/
  cloudflare-dns/     # CNAME apex, www, api → <tunnel-uuid>.cfargotunnel.com
  cloudflare-tunnel/  # Tunnel resource + ingress rules (origins are local URLs)
envs/
  prod/               # Thin root wiring modules + variables
```

Optional remote state: copy [`envs/prod/backend.hcl.example`](envs/prod/backend.hcl.example) to `backend.hcl` and run `terraform init -backend-config=backend.hcl`.

## Local topology (reference)

| Node | Hardware (your spec) | Suggested roles |
|------|----------------------|-----------------|
| **Node_light** | 2 cores, 2 threads, 4 GiB RAM | `cloudflared`, ingress controller, Next.js FE, Redis (light services) |
| **Node_heavy** | 4 cores, 8 threads, 16 GiB RAM | SQL Server, MongoDB, Kafka (+ ZooKeeper if used), Redis (if colocated), .NET APIs & gateway |

Total **~20 GiB RAM** is tight for SQL Server + Kafka + Mongo + five microservices. Use **K3s**, strict **`resources.requests` / `limits`**, and **`nodeSelector` / affinity** so heavy pods land on Node_heavy only.

## Placeholder values (fill before / during apply)

| Name | Where | Notes |
|------|-------|--------|
| `CLOUDFLARE_API_TOKEN` | Env `TF_VAR_cloudflare_api_token` or `terraform.tfvars` | Needs Zone DNS + Zero Trust / Tunnel permissions (see Cloudflare token docs). **Do not commit.** |
| `cloudflare_account_id` | `terraform.tfvars` | Dashboard → account home. |
| `zone_name` | `terraform.tfvars` | e.g. `ltt-ltc.io.vn`. |
| `tunnel_name` | `terraform.tfvars` | e.g. `ltt-ltc-prod`. |
| `origin_web_url` / `origin_api_url` | `terraform.tfvars` | HTTP URL reachable **from the cloudflared connector** (compose DNS name or K8s Service DNS). |
| Cloudflared **run token** | Cloudflare Dashboard / CLI | Provider **v4** does not expose a Terraform output for the short-lived connector token. After `terraform apply`, open **Zero Trust → Networks → Tunnels → [tunnel] → Install connector** and copy the token into **`CLOUDFLARE_TUNNEL_TOKEN`** in Compose (`deploy/docker-compose.yml`) or a Kubernetes Secret. |

Copy [`envs/prod/terraform.tfvars.example`](envs/prod/terraform.tfvars.example) to `terraform.tfvars` (gitignored).

## Terraform commands

From [`envs/prod`](envs/prod):

```bash
export TF_VAR_cloudflare_api_token="***"
terraform init
terraform plan
terraform apply
```

## GitHub Actions (this repo)

Workflows live under [`.github/workflows/`](.github/workflows/).

- **Cross-repo triggers**: FE and BE repositories send `repository_dispatch` to this repo (see below).
- **Traditional deploy**: deploy jobs run only when the payload sets `"deploy": true` (e.g. on merge). Pull-request dispatches should use `"deploy": false` so only CI runs.
- **No blue/green**: a single SSH + `docker compose pull` / `up` path (swap later for `helm upgrade` / `kubectl` when ready).

### Secrets (repository: `ltt-ltc-terraform`)

| Secret | Purpose |
|--------|---------|
| `WORKFLOW_CHECKOUT_TOKEN` | PAT or GitHub App token with `contents: read` on private FE/BE repos used for `actions/checkout` from this repo. |
| `DOCKER_USERNAME` / `DOCKER_PASSWORD` | Registry login for image push (same pattern as existing service workflows). |
| `TS_AUTHKEY` | Ephemeral Tailscale auth key for the runner (optional but matches current deploy style). |
| `SSH_PRIVATE_KEY` | SSH private key for deploy user. |
| `DEPLOY_SSH_HOST` | Tailscale or LAN IP / hostname of the compose host (**replace hard-coded IPs in service repos**). |
| `DEPLOY_SSH_USER` | SSH user (e.g. `dranov`). |
| `DEPLOY_COMPOSE_DIR` | Remote directory containing `docker compose` files (e.g. `/home/dranov/Desktop/ltt-ltc`). |
| `NEXT_PUBLIC_API_URL` | Build-arg for the frontend (`NEXT_PUBLIC_API_URL`). Alias existing repos using **`API_URL`** by copying its value here or changing this workflow line to match. |

### Wiring FE / BE repos

Each application repo should call this repo using a PAT stored there as **`DISPATCH_TOKEN`** (fine-grained: permission to trigger workflows on `ltt-ltc-terraform`, no overly broad scopes).

**On pull request** (`deploy: false`):

```yaml
- uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.DISPATCH_TOKEN }}
    repository: YOUR_ORG/ltt-ltc-terraform
    event-type: fe_ci
    client-payload: >
      {"repository":"${{ github.repository }}","ref":"${{ github.ref }}","sha":"${{ github.sha }}","deploy":false}
```

**On merge / push to default branch** (`deploy: true`), same payload with `"deploy": true` and `event-type` **`fe_deploy`** or **`be_deploy`** (see workflow files for accepted types).

Backend payloads must identify which repo image to build (implicit from `repository` field).

### Dispatch events summary

| `event-type` | Behavior |
|--------------|----------|
| `fe_ci` / `fe_deploy` | Frontend Yarn matrix build; deploy builds/pushes Docker image and updates **`ltt-ltc-web-app`** compose service when `deploy` is true (`receive-fe-dispatch.yml`). |
| `be_ci` / `be_deploy` | Single-backend-repo `dotnet build` + optional tests (`receive-be-dispatch.yml`). |
| `be_ci_all` | Builds/tests **all six** backends (`receive-be-matrix-dispatch.yml` — also runnable via **`workflow_dispatch`**). |

## Related application repos

Backend Dockerfile paths and image names match existing workflows:

| Repository suffix | Dockerfile | Compose service |
|-------------------|------------|-----------------|
| `ltt-ltc-administration-api` | `LTC.AdministrationService.HttpApi.Host/Dockerfile` | `ltt-ltc-administration-api` |
| `ltt-ltc-customer-api` | `LTC.CustomerService.HttpApi.Host/Dockerfile` | `ltt-ltc-customer-api` |
| `ltt-ltc-movie-service` | `LTC.MovieService.HttpApi.Host/Dockerfile` | `ltt-ltc-movie-api` |
| `ltt-ltc-product-api` | `LTC.ProductService.HttpApi.Host/Dockerfile` | `ltt-ltc-product-api` |
| `ltt-ltc-payment-api` | `LTC.PaymentService.HttpApi.Host/Dockerfile` | `ltt-ltc-payment-api` |
| `ltt-ltc-web-gateway` | `LTC.WebGateWay/Dockerfile` | `ltt-ltc-web-gateway` |

Image naming defaults to **`${DOCKER_USERNAME}/<repository-short-name>`** with **`ltt-ltc-movie-service`** → image **`.../ltt-ltc-movie-api`** to match compose.

## Follow-ups

- **Ansible**: bootstrap Tailscale + K3s on both nodes (outside Terraform).
- **Helm / K8s**: replace SSH compose deploy with `kubectl` / Helm when charts are ready; tunnel Terraform stays unchanged.
