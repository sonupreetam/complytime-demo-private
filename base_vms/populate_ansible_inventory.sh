#!/bin/bash
# This script populates the Ansible inventory file with information of the VM created by Vagrant

# Get Vagrant SSH configuration
VAGRANT_SSH_CONFIG=$(vagrant ssh-config)

# Add the VM's IP address to the known_hosts file to avoid SSH prompts
IP=$(echo "$VAGRANT_SSH_CONFIG" | awk '/HostName/ {print $2}')
ssh-keyscan -H "$IP" >> ~/.ssh/known_hosts 2>/dev/null
echo "IP address $IP added to known_hosts file."

# Get the SSH port from Vagrant config
PORT=$(echo "$VAGRANT_SSH_CONFIG" | awk '/Port/ {print $2}')

# Populate the Ansible inventory file with the VM's SSH configuration
# Use root user and password for demo simplicity
echo "[demo_vm]" > ../../base_ansible_env/ansible_inventory
echo "complytime-fedora-demo ansible_host=localhost ansible_user=root ansible_ssh_pass=complytime ansible_port=$PORT ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../base_ansible_env/ansible_inventory

echo "Inventory file generated successfully!"
cat ../../base_ansible_env/ansible_inventory

echo ""
echo "You can connect to the VM using the following commands:"
echo "  ssh root@localhost -p $PORT"
echo "  Password: complytime"
echo ""
echo "Or use Ansible:"
echo "  cd ../../base_ansible_env"
echo "  ansible-playbook -i ansible_inventory complytime_vm_demo.yml"
