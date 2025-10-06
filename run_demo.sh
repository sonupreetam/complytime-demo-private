#!/bin/bash

# ComplyTime Demo Runner
# This script sets up and runs the complete ComplyTime demo

set -e

# Default demo type
DEMO_TYPE="anssi"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --demo)
            DEMO_TYPE="$2"
            shift 2
            ;;
        --help|-h)
            echo "ComplyTime Demo Runner"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --demo TYPE    Demo type to run (anssi|cusp|vm|fedora|rpm|dev-binaries) [default: anssi]"
            echo "  --help, -h     Show this help message"
            echo ""
            echo "Demo Types:"
            echo "  anssi          ANSSI BP28 minimal compliance framework demo (Docker)"
            echo "  cusp           CUSP Fedora compliance framework demo with custom config (Docker)"
            echo "  vm             CUSP Fedora compliance framework demo on VM using ansible_inventory"
            echo "  fedora         Comprehensive 3-phase Fedora compliance workflow with system remediation (Docker)"
            echo "  rpm            RPM-based deployment and compliance demo (Docker)"
            echo "  dev-binaries   Development binaries workflow with local build (Docker)"
            echo ""
            echo "Examples:"
            echo "  $0                       # Run ANSSI demo (default)"
            echo "  $0 --demo anssi          # Run ANSSI demo"
            echo "  $0 --demo cusp           # Run CUSP demo"
            echo "  $0 --demo vm             # Run VM-based CUSP demo"
            echo "  $0 --demo fedora         # Run comprehensive Fedora compliance workflow"
            echo "  $0 --demo rpm            # Run RPM-based deployment demo"
            echo "  $0 --demo dev-binaries   # Run development binaries demo"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate demo type
case $DEMO_TYPE in
    anssi)
        DEMO_PLAYBOOK="complytime_complete_demo.yml"
        DEMO_NAME="ANSSI BP28"
        USE_DOCKER=true
        ;;
    cusp)
        DEMO_PLAYBOOK="complytime_cusp_demo.yml"
        DEMO_NAME="CUSP Fedora"
        USE_DOCKER=true
        ;;
    vm)
        DEMO_PLAYBOOK="complytime_vm_demo.yml"
        DEMO_NAME="CUSP Fedora VM"
        USE_DOCKER=false
        ;;
    fedora)
        DEMO_PLAYBOOK="demo_complyctl_fedora.yml"
        DEMO_NAME="Comprehensive Fedora Compliance"
        USE_DOCKER=true
        ;;
    rpm)
        DEMO_PLAYBOOK="complytime_rpm_demo.yml"
        DEMO_NAME="RPM-Based Deployment"
        USE_DOCKER=true
        ;;
    dev-binaries)
        DEMO_PLAYBOOK="complytime_dev_binaries_demo.yml"
        DEMO_NAME="Development Binaries"
        USE_DOCKER=true
        ;;
    *)
        echo "❌ Error: Invalid demo type '$DEMO_TYPE'. Use 'anssi', 'cusp', 'vm', 'fedora', 'rpm', or 'dev-binaries'"
        exit 1
        ;;
esac

echo "🚀 Starting ComplyTime $DEMO_NAME Demo Setup..."
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the complytime-demos root directory"
    exit 1
fi

if [ "$USE_DOCKER" = true ]; then
    # Podman-based demo
    # Check if Podman is running
    if ! podman ps >/dev/null 2>&1; then
        echo "❌ Error: Podman is not running. Please start Podman first."
        exit 1
    fi

    # Start the Fedora container
    echo "📦 Starting Fedora demo container..."
    podman compose up -d fedora-demo

    # Wait for container to be ready
    echo "⏳ Waiting for container to be ready..."
    sleep 10

    # Check if container is running
    if ! podman ps | grep -q complytime-fedora-demo; then
        echo "❌ Error: Container failed to start. Check logs with: podman compose logs"
        exit 1
    fi

    echo "✅ Container is running!"

    # Special handling for dev-binaries demo - cross-compile on host
    if [ "$DEMO_TYPE" = "dev-binaries" ]; then
        echo "🔧 Cross-compiling complyctl for Linux ARM64..."
        if [ -d "../complyctl" ]; then
            (cd ../complyctl && GOOS=linux GOARCH=arm64 make build) || { echo "❌ Failed to cross-compile complyctl"; exit 1; }
            echo "✅ ComplyCtl cross-compiled successfully for Linux"
        else
            echo "❌ Error: ComplyCtl repository not found at ../complyctl"
            exit 1
        fi
    fi

    # Copy Ansible files to container
    echo "📋 Copying Ansible playbooks to container..."
    podman cp base_ansible_env complytime-fedora-demo:/tmp/

    # Special handling for dev-binaries demo - copy cross-compiled binaries
    if [ "$DEMO_TYPE" = "dev-binaries" ]; then
        echo "📦 Copying cross-compiled Linux binaries to container..."
        podman cp ../complyctl/bin complytime-fedora-demo:/tmp/linux-bin
    fi


    # Run the selected demo setup
    echo "🎬 Running $DEMO_NAME demo setup..."
    podman exec complytime-fedora-demo bash -c "cd /tmp/base_ansible_env && ansible-playbook $DEMO_PLAYBOOK"
else
    # VM-based demo
    echo "🖥️  Running VM-based demo..."
    echo "📋 Using Vagrant VM infrastructure..."
    
    # Check if Vagrant is installed
    if ! command -v vagrant &> /dev/null; then
        echo "❌ Error: Vagrant is not installed. Please install Vagrant first."
        echo "   Or use Docker-based demos: ./run_demo.sh --demo anssi"
        exit 1
    fi
    
    # Use the dedicated VM demo runner
    echo "🎬 Running $DEMO_NAME demo setup on VM..."
    ./run_vm_demo.sh --vm fedora
fi

echo ""
echo "🎉 $DEMO_NAME Demo completed successfully!"
echo ""
if [ "$USE_DOCKER" = true ]; then
    echo "To connect to the demo environment:"
    echo "  podman exec -it complytime-fedora-demo bash"
    echo ""
    echo "To run individual demo commands:"
    case $DEMO_TYPE in
        anssi)
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl list'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl info anssi_bp28_minimal'"
            ;;
        fedora)
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl list'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl info cusp_fedora'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'ls -la downloads_scan*'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'cat complytime/assessment-plan.json'"
            ;;
        rpm)
            echo "  podman exec -it complytime-fedora-demo bash -c 'rpm -qa | grep complyctl'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl list'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl info cusp_fedora'"
            ;;
        dev-binaries)
            echo "  podman exec -it complytime-fedora-demo bash -c 'which complyctl'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl list'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'echo \$COMPLYTIME_DEV_MODE'"
            ;;
        *)
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl list'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl info cusp_fedora'"
            echo "  podman exec -it complytime-fedora-demo bash -c 'complyctl plan cusp_fedora --scope-config files/demo_cusp_config_plan.yml'"
            ;;
    esac
    echo ""
    echo "To stop the demo environment:"
    echo "  podman compose down"
else
    echo "To connect to the VM:"
    echo "  ssh root@localhost -p 2222"
    echo ""
    echo "To run individual demo commands on VM:"
    echo "  ssh root@localhost -p 2222 'complyctl list'"
    echo "  ssh root@localhost -p 2222 'complyctl info cusp_fedora'"
    echo "  ssh root@localhost -p 2222 'complyctl plan cusp_fedora --scope-config files/demo_cusp_config_plan.yml'"
    echo ""
    echo "To stop the VM:"
    echo "  cd base_vms/fedora && vagrant halt"
fi
echo ""
echo "🚀 Happy compliance testing!"


