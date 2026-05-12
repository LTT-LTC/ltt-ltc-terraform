# LTT-LTC Docker Swarm Infrastructure - How to Run

This guide covers setting up the LTT-LTC cinema management system infrastructure using Terraform, Ansible, and Docker Swarm across 2 physical servers connected via Tailscale.

## Prerequisites

- **Terraform** >= 1.5.0
- **Ansible** >= 2.14
- **SSH key** for server access (private key stored in `~/.ssh/`)
- **Ubuntu 22.04 LTS** on both servers
- **Tailscale** network setup (servers should have Tailscale IPs)

## Infrastructure Overview

| Server | Tailscale IP | Hardware | Role |
|--------|--------------|----------|------|
| Server 1 | 100.99.158.16 | 2c/2t/4GB | Swarm Manager, NextJS FE, API Gateway, Redis, Traefik, Cloudflared |
| Server 2 | 100.109.240.84 | 4c/8t/16GB | Swarm Worker, SQL Server, MongoDB, RabbitMQ, All .NET services |

## Quick Start

### 1. Prepare Secrets

Copy the secrets from `DevOps/secret.md` and set as environment variables:

```bash
export TF_VAR_cloudflare_api_token="your-token"
export TF_VAR_tailscale_authkey="tskey-auth-xxx"
export TF_VAR_cloudflare_tunnel_token="your-tunnel-token"
export TF_VAR_sql_sa_password="MyPassword123."
export TF_VAR_rabbitmq_user="guest"
export TF_VAR_rabbitmq_pass="guest"
```

### 2. Terraform - Provision Infrastructure

```bash
cd DevOps/ltt-ltc-terraform/envs/prod

# Initialize
terraform init

# Plan
terraform plan

# Apply (generates Ansible inventory)
terraform apply
```

**What Terraform does:**
- Creates `ansible/inventory.ini` with server IPs
- Creates `ansible/group_vars/all.yml` with secrets
- **Does NOT deploy containers** (Ansible handles that)

### 3. Ansible - Setup Docker Swarm

```bash
cd DevOps/ltt-ltc-terraform/ansible

# Test connectivity
ansible all -i inventory.ini -m ping

# Run full playbook
ansible-playbook -i inventory.ini playbook.yml
```

**What Ansible does:**
- Installs Docker CE on all nodes
- Installs Tailscale and authenticates
- Initializes Swarm on Server 1 (manager)
- Joins Server 2 as worker
- Deploys Traefik reverse proxy
- Creates Docker secrets
- Deploys application stacks

### 4. Verify Deployment

SSH to Server 1 (manager):

```bash
ssh ubuntu@100.99.158.16

# Check Swarm status
docker node ls

# Check services
docker service ls

# Check Traefik logs
docker service logs traefik_traefik

# Check application logs
docker service logs ltt-ltc_ltt-ltc-web-app
docker service logs ltt-ltc-db_ltt-ltc-administration-api
```

## Service Management

### Scaling Services

```bash
# Scale to 6 replicas under load
docker service scale ltt-ltc-db_ltt-ltc-customer-api=6

# Scale back to minimum
docker service scale ltt-ltc-db_ltt-ltc-customer-api=3
```

### Updating Services (Rolling Updates)

```bash
# Update a specific service with new image
docker service update --image dranov220805/ltt-ltc-web-app:v2.0 ltt-ltc_ltt-ltc-web-app

# Force update (pull latest tag)
docker service update --force ltt-ltc_ltt-ltc-web-app
```

### Viewing Logs

```bash
# All logs
docker service logs ltt-ltc_ltt-ltc-web-app

# Follow logs
docker service logs -f ltt-ltc_ltt-ltc-web-app

# Last 100 lines
docker service logs --tail 100 ltt-ltc_ltt-ltc-web-app
```

## GitHub Actions Deployment

### Repository Secrets Required

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password/token |
| `TS_AUTHKEY` | Tailscale auth key for GitHub Actions runner |
| `SSH_PRIVATE_KEY` | SSH private key for server access |
| `DEPLOY_SSH_HOST` | Server 1 Tailscale IP (100.99.158.16) |
| `DEPLOY_SSH_USER` | SSH user (e.g., `ubuntu`) |
| `NEXT_PUBLIC_API_URL` | Frontend API URL (https://api.ltt-ltc.io.vn) |
| `WORKFLOW_CHECKOUT_TOKEN` | GitHub PAT for checking out other repos |

### Manual Deploy via GitHub Actions

1. Go to **Actions** → **Deploy to Docker Swarm**
2. Click **Run workflow**
3. Select service to deploy (`all` or specific service)
4. Set image tag (default: `latest`)
5. Click **Run workflow**

### Automatic Deploy from FE/BE Repos

When code is pushed to main branches:

1. FE/BE repo triggers `repository_dispatch` to this repo
2. Workflow builds Docker image
3. Image is pushed to Docker Hub
4. Service is updated in Docker Swarm

## Migration from docker-compose

### Pre-Migration Checklist

- [ ] Backup all databases (SQL Server, MongoDB)
- [ ] Document current docker-compose configuration
- [ ] Ensure Tailscale is running on both servers
- [ ] Verify SSH access to both servers

### Migration Steps

1. **Stop existing services** (keep databases running):
   ```bash
   cd deploy
   docker compose stop ltt-ltc-web-app ltt-ltc-web-gateway ltt-ltc-administration-api ltt-ltc-customer-api ltt-ltc-movie-api ltt-ltc-product-api ltt-ltc-payment-api
   ```

2. **Run Terraform** to generate inventory

3. **Run Ansible** to setup Swarm and deploy stacks

4. **Update Cloudflare DNS** to point to Server 1 Traefik

5. **Verify** all services are healthy:
   ```bash
   docker service ls
   ```

6. **Stop old docker-compose** (after verification):
   ```bash
   docker compose down
   ```

## Troubleshooting

### Service stuck in "Pending"

```bash
# Check why service won't start
docker service ps <service-name> --no-trunc

# Common issues:
# - Image not found (check Docker Hub)
# - Placement constraints not met (check node labels)
# - Port conflict (check 80/443)
```

### Nodes not communicating

```bash
# Check overlay network
docker network inspect ltt-ltc-network

# Check Tailscale connectivity
ping 100.99.158.16
ping 100.109.240.84

# Restart Tailscale if needed
sudo systemctl restart tailscaled
```

### Database connection issues

```bash
# Check if databases are reachable from services
docker exec -it <container> bash
nc -zv ltt-ltc-sqlserver 1433
nc -zv ltt-ltc-mongodb 27017
nc -zv ltt-ltc-rabbitmq 5672
nc -zv ltt-ltc-redis 6379
```

### Traefik not routing

```bash
# Check Traefik dashboard (if enabled)
curl http://100.99.158.16:8080/api/rawdata

# Check Traefik logs
docker service logs traefik_traefik
```

## Network Architecture

```
Internet → Cloudflare Tunnel → Server 1 (Traefik) → Services
                                      ↓
                              Server 2 (via Tailscale overlay network)
```

**Networks:**
- `traefik-public` - External access via Traefik
- `ltt-ltc-network` - Internal service communication

## File Structure

```
DevOps/ltt-ltc-terraform/
├── terraform/
│   └── inventory.tf          # Generates Ansible inventory
├── ansible/
│   ├── inventory.tpl         # Inventory template
│   ├── ansible.cfg           # Ansible configuration
│   ├── playbook.yml          # Main playbook
│   ├── group_vars/
│   │   └── all.yml.tpl       # Variables template
│   └── roles/
│       ├── docker/           # Install Docker
│       ├── tailscale/        # Install Tailscale
│       ├── swarm-init/       # Initialize Swarm
│       ├── swarm-join/       # Join workers
│       ├── traefik/          # Deploy Traefik
│       ├── secrets/          # Docker secrets
│       └── stacks/           # Deploy app stacks
├── swarm/
│   ├── stack-server1.yml     # Server 1 services
│   └── stack-server2.yml     # Server 2 services
├── .github/workflows/
│   ├── receive-fe-dispatch.yml   # FE auto-deploy
│   ├── receive-be-dispatch.yml   # BE auto-deploy
│   └── deploy-swarm.yml          # Manual deploy
└── HOW_TO_RUN.md           # This file
```

## Security Notes

1. **Never commit secrets** - Use environment variables or GitHub Secrets
2. **SSH keys** - Use ed25519 keys, restrict to specific servers
3. **Docker secrets** - Used for DB passwords and tunnel tokens
4. **Tailscale** - Acts as VPN mesh between servers
5. **Firewall** - Only 80/443 exposed via Cloudflare Tunnel

## Support

For issues:
1. Check service logs: `docker service logs <service>`
2. Verify node status: `docker node ls`
3. Check network connectivity: `ping` between Tailscale IPs
4. Review Traefik dashboard for routing issues
