# ComplyTime VM Infrastructure

This document describes the VM infrastructure setup for ComplyTime demos, including the fixes and improvements made to integrate with the demo system.

## 🏗️ VM Infrastructure Overview

The `base_vms` directory contains Vagrant-based VM configurations for running ComplyTime demos on actual virtual machines instead of containers.

### Directory Structure
```
base_vms/
├── fedora/
│   └── Vagrantfile          # Fedora 40 VM configuration
├── rhel9/
│   └── Vagrantfile          # RHEL 9 VM configuration
└── populate_ansible_inventory.sh  # Inventory generation script
```

## 🔧 Issues Fixed

### 1. **Outdated VM Images**
- **Before**: Fedora 42 (2015) - very outdated
- **After**: Fedora 40 (current) using `generic/fedora40` box
- **Benefit**: Modern packages, security updates, better compatibility

### 2. **SSH Configuration Mismatch**
- **Before**: Complex SSH key setup, ansible user only
- **After**: Root user with password authentication for demo simplicity
- **Benefit**: Easier demo setup, matches our demo expectations

### 3. **Inventory Generation Issues**
- **Before**: Generated inventory for ansible user with SSH keys
- **After**: Generates inventory for root user with password authentication
- **Benefit**: Matches our VM demo playbooks expectations

### 4. **Missing Integration**
- **Before**: No connection between Vagrant and demo system
- **After**: Full integration with demo runner scripts
- **Benefit**: Seamless VM demo experience

## 📋 VM Configurations

### Fedora VM (`base_vms/fedora/Vagrantfile`)
```ruby
# Modern Fedora 40 configuration
config.vm.box = "generic/fedora40"
config.vm.hostname = "complytime-fedora-demo"

# libvirt provider
config.vm.provider "libvirt" do |libvirt|
  libvirt.memory = "2048"
  libvirt.cpus = 2
  libvirt.default_prefix = "complytime_"
  libvirt.machine_virtual_size = 10
end

# Demo-friendly setup
- Root password: "complytime"
- SSH root login enabled
- All required packages pre-installed
- Ansible user configured for sudo access
```

### RHEL 9 VM (`base_vms/rhel9/Vagrantfile`)
```ruby
# RHEL 9 configuration (requires subscription)
config.vm.box = "generic/rhel9"
config.vm.hostname = "rhel9"

# libvirt provider
config.vm.provider "libvirt" do |libvirt|
  libvirt.memory = "2048"
  libvirt.cpus = 2
  libvirt.default_prefix = "complytime_"
end

# Note: Uses internal Red Hat repositories
# May require valid subscription for full functionality
```

## 🚀 Usage

### Quick Start
```bash
# Run VM demo (automatically starts VM)
./run_demo.sh --demo vm

# Or use dedicated VM runner
./run_vm_demo.sh
```

### Manual VM Management
```bash
# Start Fedora VM
cd base_vms/fedora
vagrant up

# Connect to VM
vagrant ssh

# Stop VM
vagrant halt

# Destroy VM
vagrant destroy
```

### Inventory Management
The `populate_ansible_inventory.sh` script automatically:
1. Gets SSH configuration from Vagrant
2. Updates `base_ansible_env/ansible_inventory`
3. Configures connection details for our demos

## 🔐 Security Considerations

### Demo vs Production
- **Demo Setup**: Root password authentication for simplicity
- **Production**: Should use SSH keys and non-root users
- **Recommendation**: Use demo setup only for testing/development

### SSH Configuration
```bash
# Demo setup (insecure for production)
PermitRootLogin yes
PasswordAuthentication yes

# Production setup (secure)
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

## 📦 Pre-installed Packages

Both VMs come with:
- **Core packages**: git, vim, tree, tar
- **Development tools**: golang, python3-pip
- **Compliance tools**: openscap-scanner, openscap-engine-sce, scap-security-guide
- **Automation**: ansible
- **System tools**: qemu-guest-agent, openssh

## 🔄 Integration with Demo System

### Demo Runner Integration
```bash
# Main demo runner supports VM demos
./run_demo.sh --demo vm

# Dedicated VM runner with more options
./run_vm_demo.sh --vm fedora
./run_vm_demo.sh --vm rhel9
```

### Ansible Integration
```yaml
# VM demos use ansible_inventory
- name: "Run VM demo"
  hosts: demo_vm  # From ansible_inventory
  become: false
```

### File Usage
| File | Purpose | Used By |
|------|---------|---------|
| `ansible_inventory` | VM connection config | VM demos |
| `ansible.cfg` | Ansible configuration | VM demos |
| `demo_cusp_config_plan.yml` | Custom assessment plan | VM demos |
| `c2p-openscap-manifest.json.j2` | Plugin manifest template | VM demos |

## 🛠️ Troubleshooting

### Common Issues

1. **Vagrant not found**
   ```bash
   # Install Vagrant
   brew install vagrant  # macOS
   # or download from https://www.vagrantup.com/
   ```

2. **libvirt provider missing**
   ```bash
   # Install libvirt provider
   vagrant plugin install vagrant-libvirt
   ```

3. **SSH connection issues**
   ```bash
   # Check VM status
   vagrant status
   
   # Check SSH config
   vagrant ssh-config
   
   # Regenerate inventory
   ./populate_ansible_inventory.sh
   ```

4. **Package installation failures**
   ```bash
   # Check VM connectivity
   vagrant ssh -c "ping -c 3 8.8.8.8"
   
   # Check package repositories
   vagrant ssh -c "dnf repolist"
   ```

### Debug Mode
```bash
# Run Vagrant with debug output
vagrant up --debug

# Run Ansible with verbose output
ansible-playbook -i ansible_inventory complytime_vm_demo.yml -vvv
```

## 🎯 Benefits of VM Infrastructure

1. **Real-world testing**: Actual VM environment vs containers
2. **Production simulation**: Closer to real deployment scenarios
3. **Network isolation**: VMs provide better network isolation
4. **Resource control**: Configurable CPU/memory allocation
5. **Snapshot support**: Vagrant supports VM snapshots for testing

## 🔮 Future Improvements

1. **Multi-VM support**: Support for multiple VMs in same demo
2. **Network configuration**: Custom network setup for complex scenarios
3. **Storage options**: Configurable disk sizes and types
4. **Cloud integration**: Support for cloud providers (AWS, GCP, Azure)
5. **Automated testing**: CI/CD integration for VM demos

The VM infrastructure now provides a complete, integrated solution for running ComplyTime demos on actual virtual machines, with proper integration into the demo system and all configuration files being utilized effectively.
