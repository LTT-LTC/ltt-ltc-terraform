#!/usr/bin/env pwsh

# Deployment script for LTT-LTC Docker Stacks
# This script deploys both stack-server1.yml and stack-server2.yml to the Docker Swarm

Write-Host "Starting LTT-LTC Stack Deployment..." -ForegroundColor Green

# Swarm Manager IP
$SWARM_MANAGER = "100.99.158.16"
$SSH_USER = "kaka-server"

# Stack files
$STACK1_FILE = "d:\LTT\ltc\DevOps\ltt-ltc-terraform\ansible\roles\stacks\files\stack-server1.yml"
$STACK2_FILE = "d:\LTT\ltc\DevOps\ltt-ltc-terraform\ansible\roles\stacks\files\stack-server2.yml"

# Check if stack files exist
if (-not (Test-Path $STACK1_FILE)) {
    Write-Error "Stack file 1 not found: $STACK1_FILE"
    exit 1
}

if (-not (Test-Path $STACK2_FILE)) {
    Write-Error "Stack file 2 not found: $STACK2_FILE"
    exit 1
}

Write-Host "Stack files found. Preparing to deploy..." -ForegroundColor Yellow

# Commands to run on swarm manager
$commands = @(
    "echo 'Checking current stacks...'",
    "docker stack ls",
    "echo 'Removing existing stacks...'",
    "docker stack rm ltt-ltc",
    "docker stack rm ltt-ltc-db",
    "docker stack rm ltt-ltc-server2",
    "echo 'Waiting for stacks to be removed...'",
    "sleep 10",
    "echo 'Deploying stack-server1...'",
    "docker stack deploy -c /tmp/stack-server1.yml ltt-ltc",
    "echo 'Deploying stack-server2...'",
    "docker stack deploy -c /tmp/stack-server2.yml ltt-ltc-db",
    "echo 'Waiting for services to stabilize...'",
    "sleep 30",
    "echo 'Checking stack status...'",
    "docker stack ls",
    "docker service ls"
)

# Create temporary script
$tempScript = "/tmp/deploy-stacks.sh"
$scriptContent = $commands -join "`n"

Write-Host "Connecting to swarm manager at $SWARM_MANAGER..." -ForegroundColor Yellow
Write-Host "You will be prompted for SSH password." -ForegroundColor Cyan

# Copy stack files to remote server
Write-Host "Copying stack files to remote server..." -ForegroundColor Yellow
scp $STACK1_FILE "${SSH_USER}@${SWARM_MANAGER}:/tmp/stack-server1.yml"
scp $STACK2_FILE "${SSH_USER}@${SWARM_MANAGER}:/tmp/stack-server2.yml"

# Execute deployment commands
Write-Host "Executing deployment commands..." -ForegroundColor Yellow
foreach ($cmd in $commands) {
    Write-Host "Running: $cmd" -ForegroundColor Cyan
    ssh "${SSH_USER}@${SWARM_MANAGER}" "$cmd"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Command failed: $cmd"
        exit 1
    }
    Start-Sleep -Seconds 2
}

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "You can check the status with: ssh ${SSH_USER}@${SWARM_MANAGER} 'docker service ls'" -ForegroundColor Cyan
