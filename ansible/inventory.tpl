[swarm_manager]
${manager_ip} ansible_user=${ssh_user}

[swarm_workers]
${worker_ip} ansible_user=${ssh_user}

[swarm_nodes:children]
swarm_manager
swarm_workers

[server1]
${manager_ip} ansible_user=${ssh_user}

[server2]
${worker_ip} ansible_user=${ssh_user}
