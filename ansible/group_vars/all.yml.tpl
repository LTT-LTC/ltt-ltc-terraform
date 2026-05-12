---
# Tailscale
tailscale_authkey: "${tailscale_authkey}"

# Cloudflare
tunnel_token: "${cloudflare_tunnel_token}"

# Database secrets
sql_sa_password: "${sql_sa_password}"
rabbitmq_user: "${rabbitmq_user}"
rabbitmq_pass: "${rabbitmq_pass}"

# Swarm configuration
manager_advertise_addr: "{{ hostvars[groups['swarm_manager'][0]]['ansible_host'] }}"

# Service scaling
min_replicas: 3
max_replicas: 6
