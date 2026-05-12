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
| `WORKFLOW_CHECKOUT_TOKEN` | Credential used by `actions/checkout` to clone **private** FE/BE repos from this orchestrator repo (see [WORKFLOW_CHECKOUT_TOKEN](#workflow_checkout_token) below). |
| `DOCKER_USERNAME` / `DOCKER_PASSWORD` | Registry login for image push (same pattern as existing service workflows). |
| `TS_AUTHKEY` | Ephemeral Tailscale auth key for the runner (optional but matches current deploy style). |
| `SSH_PRIVATE_KEY` | SSH private key for deploy user. |
| `DEPLOY_SSH_HOST` | Tailscale or LAN IP / hostname of the compose host (**replace hard-coded IPs in service repos**). |
| `DEPLOY_SSH_USER` | SSH user (e.g. `dranov`). |
| `DEPLOY_COMPOSE_DIR` | Remote directory containing `docker compose` files (e.g. `/home/dranov/Desktop/ltt-ltc`). |
| `NEXT_PUBLIC_API_URL` | Build-arg for the frontend (`NEXT_PUBLIC_API_URL`). Alias existing repos using **`API_URL`** by copying its value here or changing this workflow line to match. |

### WORKFLOW_CHECKOUT_TOKEN

Workflows in this repo clone **other** repositories (frontend + backend services). The default **`GITHUB_TOKEN`** only has access to **this** repo, so checkouts must use a separate credential stored as **`WORKFLOW_CHECKOUT_TOKEN`**.

**What to store:** The full token string GitHub shows **once** when you create it (e.g. `github_pat_...` for fine-grained PATs). Paste it into **Settings → Secrets and variables → Actions** on **`ltt-ltc-terraform`** under the name **`WORKFLOW_CHECKOUT_TOKEN`**. There is no fixed public value — each token is unique.

**Fine-grained Personal Access Token (recommended setup)**

1. **Developer settings → Fine-grained tokens → Generate new token.**
2. **Resource owner**: your user or org that owns the application repos.
3. **Repository access**: **All repositories** *or* **Only select repositories** — if you select, you must include **every** repo this workflow clones (e.g. `ltt-ltc-web-app`, `ltt-ltc-web-gateway`, and each microservice repo). Missing one repo causes **403** on that checkout.
4. **Repository permissions → Contents: Read-only** (read is enough for `git fetch` / checkout).

**Organization SSO (mandatory for many orgs)**

If repositories live under an org that enforces **SAML SSO**, open the token after creation → **Configure SSO** → **Authorize** next to that organization. Until authorized, GitHub returns **403** for private org repos even if you are an org owner.

**Misleading error message**

If checkout fails with:

`remote: Write access to repository not granted`  
`fatal: unable to access 'https://github.com/ORG/REPO/': The requested URL returned error: 403`

GitHub often uses that wording when the token **cannot access the repo at all** (not that push access is required). Typical fixes: add the repo under **Repository access** on the fine-grained token, **authorize SSO** for the org, or regenerate the token and re-paste the secret (no stray spaces or line breaks).

**Classic PAT (simpler alternative)**

**Developer settings → Personal access tokens (classic) → Generate**, scope **`repo`** (full control of private repositories). Store the token as **`WORKFLOW_CHECKOUT_TOKEN`**. This avoids forgetting a repo in the fine-grained allow list.

**GitHub App (optional)**

Instead of a long-lived PAT, install a **GitHub App** on all required repos and use an action such as **`actions/create-github-app-token`** to mint a short-lived installation token for `actions/checkout`. That requires small workflow changes beyond the current PAT-based setup.

**Sanity check**

Confirm each workflow step that checks out an application repo passes **`token: ${{ secrets.WORKFLOW_CHECKOUT_TOKEN }}`** (already used in this repo’s reusable and dispatch workflows).

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
| `fe_ci` / `fe_deploy` | Frontend Yarn matrix build; deploy builds/pushes Docker image and updates **`ltt-ltc-web-app`** Swarm service via `docker service update` (`receive-fe-dispatch.yml`). |
| `be_ci` / `be_deploy` | Single-backend-repo `dotnet build` + optional tests; deploy updates Swarm service via `docker service update` (`receive-be-dispatch.yml`). |
| `be_ci_all` | Builds/tests **all six** backends (`receive-be-matrix-dispatch.yml` — also runnable via **`workflow_dispatch`**). |
| `deploy-swarm` | Manual deployment workflow to update Swarm services (`deploy-swarm.yml`). |

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

## Infrastructure: Terraform + Ansible + Docker Swarm

This repository now includes complete infrastructure provisioning for the LTT-LTC cinema management system using **Terraform** (Cloudflare + inventory generation), **Ansible** (server configuration + Docker Swarm), and **Docker Swarm** (container orchestration).

### Architecture

| Component | Responsibility |
|-----------|----------------|
| **Terraform** | Cloudflare DNS/Tunnel + generate Ansible inventory |
| **Ansible** | Install Docker, Tailscale, initialize Swarm, deploy services |
| **Docker Swarm** | Container orchestration across 2 servers |

### Server Topology

| Server | Tailscale IP | Hardware | Swarm Role | Services |
|--------|--------------|----------|------------|----------|
| Server 1 | 100.99.158.16 | 2c/2t/4GB | **Manager** | NextJS FE, API Gateway, Redis, Traefik, Cloudflared |
| Server 2 | 100.109.240.84 | 4c/8t/16GB | **Worker** | SQL Server, MongoDB, RabbitMQ, All .NET APIs |

### Quick Start

```bash
# 1. Set secrets as environment variables
export TF_VAR_cloudflare_api_token="xxx"
export TF_VAR_tailscale_authkey="tskey-auth-xxx"
export TF_VAR_cloudflare_tunnel_token="xxx"

# 2. Terraform - generates Ansible inventory
cd envs/prod
terraform init
terraform apply

# 3. Ansible - sets up Docker Swarm and deploys stacks
cd ../../ansible
ansible-playbook -i inventory.ini playbook.yml

# 4. Verify
docker node ls
docker service ls
```

See **[HOW_TO_RUN.md](HOW_TO_RUN.md)** for detailed instructions.

### Project Structure

```
ltt-ltc-terraform/
├── envs/prod/                 # Main Terraform (Cloudflare + inventory)
├── ansible/                   # Ansible playbook and roles
│   ├── playbook.yml
│   ├── inventory.tpl
│   ├── group_vars/
│   └── roles/
│       ├── docker/            # Install Docker CE
│       ├── tailscale/         # Install Tailscale
│       ├── swarm-init/        # Initialize Swarm manager
│       ├── swarm-join/        # Join worker nodes
│       ├── traefik/           # Deploy Traefik reverse proxy
│       ├── secrets/           # Docker secrets
│       └── stacks/            # Deploy application stacks
├── swarm/                     # Docker Swarm stack files
│   ├── stack-server1.yml      # Server 1 services (FE, Gateway, Redis)
│   ├── stack-server2.yml      # Server 2 services (DBs, .NET APIs)
│   └── traefik.yml            # Traefik configuration
└── .github/workflows/         # CI/CD workflows
    ├── receive-fe-dispatch.yml   # Frontend auto-deploy
    ├── receive-be-dispatch.yml   # Backend auto-deploy
    └── deploy-swarm.yml          # Manual deployment
```

### Deployment Workflow

FE/BE repositories trigger `repository_dispatch` to deploy to Docker Swarm:

1. Build Docker image
2. Push to Docker Hub
3. `docker service update --image <new-image> --force <service>`

Services use rolling updates with 3-6 replicas (min-max scaling).

### Docker Swarm Features

- **Overlay networks** via Tailscale for cross-server communication
- **Placement constraints** ensure services run on correct servers
- **Rolling updates** with automatic rollback on failure
- **Health checks** for all services
- **Docker secrets** for sensitive data
- **Traefik ingress** with automatic service discovery

### Migration from docker-compose

See **[HOW_TO_RUN.md](HOW_TO_RUN.md)** → "Migration from docker-compose" section.
