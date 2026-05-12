#!/bin/bash

# Simple deployment script for LTT-LTC Docker Stacks
# Run this script on the swarm manager (100.99.158.16)

echo "=== LTT-LTC Stack Redeployment ==="
echo "Current stacks:"
docker stack ls

echo ""
echo "Removing existing stacks..."
docker stack rm ltt-ltc 2>/dev/null || true
docker stack rm ltt-ltc-db 2>/dev/null || true
docker stack rm ltt-ltc-server2 2>/dev/null || true

echo "Waiting for stacks to be removed..."
sleep 15

echo ""
echo "Deploying stack-server1..."
docker stack deploy -c /tmp/stack-server1.yml ltt-ltc

echo ""
echo "Deploying stack-server2..."
docker stack deploy -c /tmp/stack-server2.yml ltt-ltc-db

echo ""
echo "Waiting for services to stabilize..."
sleep 30

echo ""
echo "Final stack status:"
docker stack ls
echo ""
echo "Service status:"
docker service ls

echo ""
echo "=== Deployment Complete ==="
