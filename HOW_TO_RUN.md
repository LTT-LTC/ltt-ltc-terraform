# LTT-LTC Docker Swarm Infrastructure - How to Run

This guide covers setting up the LTT-LTC cinema management system infrastructure using Terraform, Ansible, and Docker Swarm across 2 physical servers connected via Tailscale.

## Prerequisites

- **Terraform** >= 1.5.0
- **Ansible** >= 2.14
- **SSH key** for server access (private key stored in `~/.ssh/`)
- **Ubuntu 22.04 LTS** on both servers
- **Tailscale** network setup (servers should have Tailscale IPs)
- **Domain**: `ltt-ltc.io.vn` with subdomains configured in Cloudflare
- **Cloudflare Tunnel Token** for secure public access (no open ports needed)
- **GitHub Secrets** configured in each BE/FE repository for auto-deployment

### Required Secrets (for GitHub Actions auto-deployment)

Configure these in each service repository (Settings → Secrets and variables):

| Secret | Description | Required In |
|--------|-------------|-------------|
| `DOCKER_USERNAME` | Docker Hub username | All BE + FE repos |
| `DOCKER_PASSWORD` | Docker Hub password/token | All BE + FE repos |
| `TS_AUTHKEY` | Tailscale auth key | All BE + FE repos |
| `SSH_PRIVATE_KEY` | SSH private key for server access | All BE + FE repos |

## Infrastructure Overview

| Server | Tailscale IP | Public IP | Hardware | Role |
|--------|--------------|-----------|----------|------|
| kaka-server | 100.99.158.16 | - | 2c/2t/4GB | Swarm Manager, NextJS FE, API Gateway, Redis, Traefik, Cloudflared, Portainer1 |
| dranov-server | 100.109.240.84 | - | 4c/8t/16GB | Swarm Worker, SQL Server, MongoDB, RabbitMQ, All .NET services, Portainer2, Monitoring |

## Domain & Subdomain Configuration

| Subdomain | Service | Server | Access |
|-----------|---------|--------|--------|
| `ltt-ltc.io.vn` | NextJS Frontend | kaka-server | Public via Cloudflare |
| `www.ltt-ltc.io.vn` | NextJS Frontend | kaka-server | Public via Cloudflare |
| `api.ltt-ltc.io.vn` | Web Gateway (YARP) | kaka-server | Public via Cloudflare |
| `portainer1.ltt-ltc.io.vn` | Portainer (kaka-server) | kaka-server | Public via Cloudflare |
| `portainer2.ltt-ltc.io.vn` | Portainer (dranov-server) | dranov-server | Public via Cloudflare |
| `monitoring.ltt-ltc.io.vn` | Grafana | dranov-server | Public via Cloudflare |

**Internal Services (No public subdomain):**
- Prometheus: `http://100.109.240.84:9090`
- All Backend APIs: Internal via Docker Swarm network

## Complete Deployment Guide

### Phase 1: Server Preparation

#### 1.1 Prepare Both Servers

Ensure both servers have:
- Ubuntu 22.04 LTS installed
- SSH access with key authentication
- Tailscale installed and authenticated
- Docker installed (or let Ansible install it)

#### 1.2 Verify SSH Access

```bash
# From your local machine, test SSH to both servers
ssh kaka-server@100.99.158.16 "echo 'kaka-server OK'"
ssh kaka-server@100.109.240.84 "echo 'dranov-server OK'"
```

### Phase 2: Environment Setup

#### 2.1 Prepare Secrets

Copy the secrets from `DevOps/secret.md` and set as environment variables:

```bash
export TF_VAR_cloudflare_api_token="your-token"
export TF_VAR_tailscale_authkey="tskey-auth-xxx"
export TF_VAR_cloudflare_tunnel_token="your-tunnel-token"
export TF_VAR_sql_sa_password="MyPassword123."
export TF_VAR_rabbitmq_user="guest"
export TF_VAR_rabbitmq_pass="guest"
```

### Phase 3: Terraform - Provision Infrastructure

```bash
cd DevOps/ltt-ltc-terraform/envs/prod

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan

# Apply (generates Ansible inventory and group_vars)
terraform apply
```

**What Terraform does:**
- Creates `ansible/inventory.ini` with server IPs
- Creates `ansible/group_vars/all.yml` with secrets
- **Does NOT deploy containers** (Ansible handles that)

### Phase 4: Ansible - Setup Docker Swarm

```bash
cd DevOps/ltt-ltc-terraform/ansible

# Test connectivity to all nodes
ansible all -i inventory.ini -m ping

# Run full playbook (this sets up everything)
ansible-playbook -i inventory.ini playbook.yml
```

**What Ansible does:**
- Installs Docker CE on all nodes
- Installs Tailscale and authenticates
- Initializes Swarm on kaka-server (manager)
- Joins dranov-server as worker
- Deploys Traefik reverse proxy
- Creates Docker secrets
- Deploys application stacks (ltt-ltc, ltt-ltc-db)
- Deploys monitoring stack (Prometheus, Grafana, Node Exporter, cAdvisor)
- Copies prometheus.yml configuration
- Initializes SQL Server databases (runs init.sql)
- Initializes MongoDB replica set

### Phase 5: Verify Deployment

After Ansible completes, SSH to kaka-server (manager) to verify everything:

```bash
ssh kaka-server@100.99.158.16

# Check Swarm status - should show 2 nodes (1 manager, 1 worker)
docker node ls

# Expected output:
# ID                            HOSTNAME       STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
# xxxxxx *                      kaka-server    Ready     Active         Leader           24.0.7
# yyyyyy                        dranov-server  Ready     Active                          24.0.7

# Check all 3 stacks are deployed
docker stack ls
# Expected:
# NAME                SERVICES
# ltt-ltc             5
# ltt-ltc-db          9
# ltt-ltc-monitoring  4

# Check all services are running
docker service ls

# Check Prometheus is running (1/1 replicas)
docker service ls | grep prometheus

# Check databases were initialized
docker exec ltt-ltc-db_ltt-ltc-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'MyPassword123.' \
  -Q "SELECT name FROM sys.databases WHERE name LIKE 'LTC_%'"
```

### Phase 6: Manual Recovery (if needed)

If Ansible fails at any step, you can manually complete the setup:

```bash
# SSH to manager node
ssh kaka-server@100.99.158.16

# Deploy specific stack
docker stack deploy -c /opt/stacks/stack-server1.yml ltt-ltc
docker stack deploy -c /opt/stacks/stack-server2.yml ltt-ltc-db
docker stack deploy -c /opt/stacks/monitoring-stack.yml ltt-ltc-monitoring

# Or redeploy all
docker stack rm ltt-ltc ltt-ltc-db ltt-ltc-monitoring
docker stack deploy -c /opt/stacks/stack-server1.yml ltt-ltc
docker stack deploy -c /opt/stacks/stack-server2.yml ltt-ltc-db
docker stack deploy -c /opt/stacks/monitoring-stack.yml ltt-ltc-monitoring
```

### Phase 7: Post-Deployment Setup (Manual)

The following steps require manual configuration after Ansible completes:

#### 7.1 Configure Grafana

1. **Login to Grafana**: https://monitoring.ltt-ltc.io.vn
   - Username: `admin`
   - Password: `admin`

2. **Add Prometheus Data Source**:
   - Configuration → Data Sources → Add data source
   - Select **Prometheus**
   - URL: `http://prometheus:9090`
   - Click **Save & Test**

3. **Import Dashboards**:
   - Create → Import
   - Import these dashboard IDs:
     - Node Exporter Full: `1860`
     - Docker Swarm: `11575`
     - cAdvisor: `14282`

#### 7.2 Verify Prometheus Targets

```bash
ssh kaka-server@100.99.158.16

# Check all targets are being scraped
curl http://100.109.240.84:9090/api/v1/status/targets

# Check Prometheus health
curl http://100.109.240.84:9090/-/healthy
```

### Phase 8: Verify Full Stack

#### 8.1 Check All Stacks

```bash
# List all stacks
docker stack ls

# Expected output:
# NAME                SERVICES
# ltt-ltc             5
# ltt-ltc-db          9
# ltt-ltc-monitoring  4
```

#### 8.2 Check Service Status

```bash
# Check all services with their replica status
docker service ls --format 'table {{.Name}}\t{{.Replicas}}\t{{.Image}}'

# Check specific stack services
docker stack services ltt-ltc
docker stack services ltt-ltc-db
docker stack services ltt-ltc-monitoring
```

#### 8.3 Verify Domains

```bash
# Test main domain
curl -s -I https://ltt-ltc.io.vn

# Test API domain
curl -s -I https://api.ltt-ltc.io.vn

# Test Portainer1
curl -s -I https://portainer1.ltt-ltc.io.vn

# Test Portainer2
curl -s -I https://portainer2.ltt-ltc.io.vn

# Test Grafana
curl -s -I https://monitoring.ltt-ltc.io.vn

# Test internal services via IP
# Prometheus
curl -s http://100.109.240.84:9090/-/healthy

# Grafana (if domains not working)
curl -s http://100.109.240.84:3000/api/health
```

## Debugging & Troubleshooting Guide

### Essential Debug Commands

#### List All Stacks and Services

```bash
# SSH to manager node (kaka-server)
ssh kaka-server@100.99.158.16

# List all stacks
docker stack ls

# List all services with status
docker service ls

# List services in specific stack
docker stack services ltt-ltc
docker stack services ltt-ltc-db
docker stack services ltt-ltc-monitoring

# Detailed service status with replica info
docker service ls --format 'table {{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}'

# Check tasks (containers) for a service
docker service ps ltt-ltc-db_ltt-ltc-administration-api

# Check all tasks across all services
docker service ps $(docker service ls -q)
```

#### View Service Logs

```bash
# View logs for a service
docker service logs ltt-ltc_ltt-ltc-web-app

# Follow logs (real-time)
docker service logs -f ltt-ltc_ltt-ltc-web-app

# Last 100 lines
docker service logs --tail 100 ltt-ltc-db_ltt-ltc-administration-api

# Show timestamps
docker service logs --tail 50 --timestamps ltt-ltc-db_ltt-ltc-customer-api

# Raw output (no truncation)
docker service logs --tail 10 --raw ltt-ltc-db_ltt-ltc-movie-api

# Logs from all tasks (including failed ones)
docker service ps ltt-ltc-db_ltt-ltc-payment-api --no-trunc
```

#### Debug Failed Services

```bash
# Check why a service has failed replicas
docker service ps ltt-ltc-db_ltt-ltc-product-api

# Inspect service details
docker service inspect ltt-ltc-db_ltt-ltc-product-api --pretty

# Check service events (creation, updates, failures)
docker service inspect ltt-ltc-db_ltt-ltc-product-api --format '{{json .UpdateStatus}}'

# Check constraints and placement
docker service inspect ltt-ltc-db_ltt-ltc-product-api --format '{{json .Spec.TaskTemplate.Placement}}'
```

#### Network Debugging

```bash
# List all networks
docker network ls

# Inspect overlay network
docker network inspect ltt-ltc-network

# Check network connectivity between services
docker run --rm --network ltt-ltc-network alpine ping -c 3 ltt-ltc-redis

# Test database connectivity
docker run --rm --network ltt-ltc-network alpine nc -zv ltt-ltc-sqlserver 1433
docker run --rm --network ltt-ltc-network alpine nc -zv ltt-ltc-mongodb 27017
docker run --rm --network ltt-ltc-network alpine nc -zv ltt-ltc-rabbitmq 5672
docker run --rm --network ltt-ltc-network alpine nc -zv ltt-ltc-redis 6379
```

#### Container-Level Debugging

```bash
# List all containers on a node
docker ps -a

# Exec into a running container
docker exec -it <container-id> bash

# Check container logs directly
docker logs <container-id>
docker logs --tail 50 -f <container-id>

# Check resource usage
docker stats

# Inspect container
docker inspect <container-id>
```

### Common Issues and Fixes

#### Issue: Services stuck in "Pending" or 0/1 replicas

```bash
# Check node availability
docker node ls

# Check if node labels are correct
docker node inspect kaka-server --format '{{json .Spec.Labels}}'
docker node inspect dranov-server --format '{{json .Spec.Labels}}'

# Set node labels if missing
ssh kaka-server@100.99.158.16 "docker node update --label-add server=1 kaka-server"
ssh kaka-server@100.99.158.16 "docker node update --label-add server=2 dranov-server"

# Check resource constraints
docker system df

# Check if required ports are available
netstat -tlnp | grep -E '80|443|9000|3000|9090'
```

#### Issue: Redis Connection Errors

```bash
# Verify Redis is running
docker service ls | grep redis

# Check Redis logs
docker service logs ltt-ltc_ltt-ltc-redis

# Test Redis connectivity from BE service node
ssh kaka-server@100.109.240.84 "docker run --rm --network ltt-ltc-network redis:7-alpine redis-cli -h ltt-ltc_ltt-ltc-redis ping"

# Restart Redis if needed
docker service update --force ltt-ltc_ltt-ltc-redis
```

#### Issue: Database Connection Failures

```bash
# Check SQL Server status
docker service logs ltt-ltc-db_ltt-ltc-sqlserver --tail 50

# Test SQL Server connection
ssh kaka-server@100.109.240.84 "docker exec ltt-ltc-db_ltt-ltc-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'MyPassword123.' -Q 'SELECT 1'"

# Check MongoDB status
docker service logs ltt-ltc-db_ltt-ltc-mongodb --tail 50

# Check MongoDB replica set status
ssh kaka-server@100.109.240.84 "docker exec ltt-ltc-db_ltt-ltc-mongodb mongosh --eval 'rs.status()'"
```

#### Issue: Traefik Not Routing

```bash
# Check Traefik service
docker service logs traefik_traefik --tail 50

# Check Traefik dashboard (if enabled)
curl http://100.99.158.16:8080/api/rawdata

# Verify Traefik labels on services
docker service inspect ltt-ltc_ltt-ltc-web-app --format '{{json .Spec.Labels}}'
docker service inspect ltt-ltc_ltt-ltc-web-gateway --format '{{json .Spec.Labels}}'

# Restart Traefik
docker service update --force traefik_traefik
```

#### Issue: Cloudflare Tunnel Not Working

```bash
# Check cloudflared logs
docker service logs ltt-ltc-server1_cloudflared --tail 50

# Check tunnel status
curl -s https://ltt-ltc.io.vn | head -20

# Verify tunnel token is correct
docker secret ls | grep cloudflare
```

#### Issue: Portainer/Grafana Not Accessible

```bash
# Check Portainer service status
docker service ls | grep portainer

# Check Grafana service status
docker service ls | grep grafana

# View logs
docker service logs ltt-ltc-server1_portainer-kaka --tail 50
docker service logs ltt-ltc-monitoring_grafana --tail 50

# Test direct IP access if domains fail
# Portainer on kaka-server
curl -s http://100.99.158.16:9000/api/status

# Portainer on dranov-server
curl -s http://100.109.240.84:9000/api/status

# Grafana
curl -s http://100.109.240.84:3000/api/health
```

### Restart and Recovery Commands

```bash
# Restart a specific service
docker service update --force ltt-ltc-db_ltt-ltc-administration-api

# Restart entire stack
docker stack deploy -c /opt/stacks/stack-server2.yml ltt-ltc-db

# Remove and redeploy a stack (WARNING: removes all services)
docker stack rm ltt-ltc-db
docker stack deploy -c /opt/stacks/stack-server2.yml ltt-ltc-db

# Update image for a service
docker service update --image dranov220805/ltt-ltc-administration-api:latest ltt-ltc-db_ltt-ltc-administration-api

# Rollback failed service update
docker service update --rollback ltt-ltc-db_ltt-ltc-administration-api
```

### Health Check Commands

```bash
# Check all BE API health endpoints
for service in administration customer movie product payment; do
  echo "Checking $service-api..."
  curl -s http://ltt-ltc-$service-api:8080/health || echo "FAILED"
done

# Check Web Gateway
curl -s http://ltt-ltc-web-gateway:8080/health

# Check all databases
# SQL Server
sqlcmd -S ltt-ltc-sqlserver,1433 -U sa -P 'MyPassword123.' -Q "SELECT 1"

# MongoDB
mongosh mongodb://ltt-ltc-mongodb:27017/ltt_ltc --eval "db.adminCommand('ping')"

# Redis
redis-cli -h ltt-ltc-redis ping

# RabbitMQ
curl -s -u guest:guest http://ltt-ltc-rabbitmq:15672/api/health/checks/virtual-hosts
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
