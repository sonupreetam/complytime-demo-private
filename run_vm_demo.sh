#!/bin/bash

# ComplyTime VM Demo Runner
# This script sets up and runs the ComplyTime demo on a Vagrant VM

set -e

# Default VM type
VM_TYPE="fedora"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --vm)
            VM_TYPE="$2"
            shift 2
            ;;
        --help|-h)
            echo "ComplyTime VM Demo Runner"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --vm TYPE      VM type to use (fedora|rhel9) [default: fedora]"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "VM Types:"
            echo "  fedora         Fedora 40 VM with CUSP compliance framework"
            echo "  rhel9          RHEL 9 VM (requires Red Hat subscription)"
            echo ""
            echo "Examples:"
            echo "  $0                    # Run Fedora VM demo (default)"
            echo "  $0 --vm fedora        # Run Fedora VM demo"
            echo "  $0 --vm rhel9         # Run RHEL 9 VM demo"
            echo ""
            echo "Prerequisites:"
            echo "  - Vagrant installed"
            echo "  - libvirt provider for Vagrant"
            echo "  - SSH key pair in ~/.ssh/id_rsa"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate VM type
case $VM_TYPE in
    fedora)
        VM_DIR="base_vms/fedora"
        VM_NAME="Fedora 40"
        ;;
    rhel9)
        VM_DIR="base_vms/rhel9"
        VM_NAME="RHEL 9"
        ;;
    *)
        echo "❌ Error: Invalid VM type '$VM_TYPE'. Use 'fedora' or 'rhel9'"
        exit 1
        ;;
esac

echo "🚀 Starting ComplyTime $VM_NAME VM Demo Setup..."
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the complytime-demos root directory"
    exit 1
fi

# Check if Vagrant is installed
if ! command -v vagrant &> /dev/null; then
    echo "❌ Error: Vagrant is not installed. Please install Vagrant first."
    exit 1
fi

# Check if VM directory exists
if [ ! -d "$VM_DIR" ]; then
    echo "❌ Error: VM directory '$VM_DIR' not found"
    exit 1
fi

# Navigate to VM directory
cd "$VM_DIR"

# Check if VM is already running
if vagrant status | grep -q "running"; then
    echo "⚠️  VM is already running. Stopping it first..."
    vagrant halt
fi

# Start the VM
echo "📦 Starting $VM_NAME VM..."
vagrant up

# Wait for VM to be ready
echo "⏳ Waiting for VM to be ready..."
sleep 10

# Check if VM is running
if ! vagrant status | grep -q "running"; then
    echo "❌ Error: VM failed to start. Check logs with: vagrant up --debug"
    exit 1
fi

echo "✅ VM is running!"

# The populate_ansible_inventory.sh script should have been executed automatically
# by the Vagrant trigger, but let's make sure the inventory is up to date
echo "📋 Updating Ansible inventory..."
./populate_ansible_inventory.sh

# Navigate back to root directory
cd ../..

# Run the VM demo
echo "🎬 Running ComplyTime $VM_NAME demo on VM..."
cd base_ansible_env
ansible-playbook -i ansible_inventory complytime_vm_demo.yml
cd ..

echo ""
echo "🎉 $VM_NAME VM Demo completed successfully!"
echo ""
echo "To connect to the VM:"
echo "  cd $VM_DIR"
echo "  vagrant ssh"
echo ""
echo "To run individual demo commands on VM:"
echo "  cd $VM_DIR"
echo "  vagrant ssh -c 'complyctl list'"
echo "  vagrant ssh -c 'complyctl info cusp_fedora'"
echo "  vagrant ssh -c 'complyctl plan cusp_fedora --scope-config files/demo_cusp_config_plan.yml'"
echo ""
echo "To stop the VM:"
echo "  cd $VM_DIR"
echo "  vagrant halt"
echo ""
echo "To destroy the VM:"
echo "  cd $VM_DIR"
echo "  vagrant destroy"
echo ""
echo "🚀 Happy compliance testing on VMs!"
