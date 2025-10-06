# ComplyTime Demo Improvements

This document outlines the improvements made to the ComplyTime demo setup to better utilize the existing configuration files and consolidate the demo approaches.

## 🎯 Improvements Implemented

### 1. **Template Usage Integration**
- **Updated** `setup_complete_demo.yml` to use the `c2p-openscap-manifest.json.j2` template instead of hardcoded content
- **Benefit**: Centralized manifest configuration, easier maintenance, consistent plugin setup

### 2. **CUSP Framework Demo Creation**
- **Created** `complytime_cusp_demo.yml` - Complete CUSP Fedora demo
- **Created** `setup_cusp_demo.yml` - CUSP-specific setup playbook
- **Created** `run_cusp_demo_commands.yml` - CUSP demo command execution
- **Uses** `demo_cusp_config_plan.yml` for custom assessment plan configuration
- **Benefit**: Demonstrates CUSP framework with custom rule inclusion/exclusion

### 3. **VM-Based Demo Support**
- **Created** `complytime_vm_demo.yml` - VM-based demo using ansible_inventory
- **Created** `setup_vm_demo.yml` - VM-specific setup playbook  
- **Created** `run_vm_demo_commands.yml` - VM demo command execution
- **Uses** `ansible_inventory` and `ansible.cfg` for VM connection
- **Benefit**: Real-world VM deployment scenario, uses existing inventory configuration

### 4. **Unified Demo Runner**
- **Enhanced** `run_demo.sh` with command-line options
- **Supports** three demo types: `anssi`, `cusp`, `vm`
- **Consolidates** all demo approaches into a single entry point
- **Benefit**: Easy switching between demo types, consistent user experience

## 📁 File Usage Matrix

| File | ANSSI Demo | CUSP Demo | VM Demo | Purpose |
|------|------------|-----------|---------|---------|
| `demo_cusp_config_plan.yml` | ❌ | ✅ | ✅ | Custom CUSP assessment plan |
| `c2p-openscap-manifest.json.j2` | ✅ | ✅ | ✅ | OpenSCAP plugin manifest template |
| `ansible_inventory` | ❌ | ❌ | ✅ | VM connection configuration |
| `ansible.cfg` | ❌ | ❌ | ✅ | Ansible configuration for VM demos |

## 🚀 Usage Examples

### Run ANSSI Demo (Default)
```bash
./run_demo.sh
# or
./run_demo.sh --demo anssi
```

### Run CUSP Demo with Custom Configuration
```bash
./run_demo.sh --demo cusp
```

### Run VM-Based Demo
```bash
./run_demo.sh --demo vm
```

### Get Help
```bash
./run_demo.sh --help
```

## 🏗️ Demo Architecture

### Docker-Based Demos (ANSSI & CUSP)
```
run_demo.sh --demo [anssi|cusp]
    ↓
Docker Container (complytime-fedora-demo)
    ↓
Ansible Playbooks
    ↓
ComplyTime Setup & Execution
```

### VM-Based Demo
```
run_demo.sh --demo vm
    ↓
Vagrant VM (via ansible_inventory)
    ↓
Ansible Playbooks (using ansible.cfg)
    ↓
ComplyTime Setup & Execution
```

## 📋 Configuration Files Now Utilized

### 1. `demo_cusp_config_plan.yml`
- **Used in**: CUSP and VM demos
- **Purpose**: Custom assessment plan with specific controls and rules
- **Features**:
  - Account Protection (cusp_fedora_4-1)
  - Sudo Configuration (cusp_fedora_4-2)
  - Firewall Configuration (cusp_fedora_5-2) with exclusions

### 2. `c2p-openscap-manifest.json.j2`
- **Used in**: All demos
- **Purpose**: OpenSCAP plugin manifest template
- **Features**:
  - Dynamic SHA256 checksum injection
  - Configurable plugin parameters
  - Consistent plugin setup across demos

### 3. `ansible_inventory`
- **Used in**: VM demo
- **Purpose**: VM connection configuration
- **Features**:
  - SSH connection details (localhost:2222)
  - Authentication credentials
  - Host-specific configuration

### 4. `ansible.cfg`
- **Used in**: VM demo
- **Purpose**: Ansible configuration
- **Features**:
  - Inventory file reference
  - Remote user settings
  - Python interpreter configuration

## 🎉 Benefits Achieved

1. **No More Unused Files**: All configuration files are now actively used
2. **Consolidated Approach**: Single entry point for all demo types
3. **Template Reuse**: OpenSCAP manifest template used across all demos
4. **VM Support**: Real-world VM deployment scenarios
5. **Custom Configuration**: CUSP framework with custom assessment plans
6. **Better Documentation**: Clear usage examples and architecture overview

## 🔧 Technical Details

### Template Integration
The OpenSCAP manifest template now uses Ansible variables:
```yaml
- name: "Create OpenSCAP plugin manifest using template"
  template:
    src: "templates/c2p-openscap-manifest.json.j2"
    dest: "{{ complyctl_workspace }}/plugins/c2p-openscap-manifest.json"
    mode: "0644"
  vars:
    result_plugin_checksum: "{{ plugin_checksum }}"
```

### Custom Assessment Plan Usage
CUSP demos use the custom configuration:
```yaml
- name: "Generate assessment plan with CUSP custom configuration"
  command: "complyctl plan {{ demo_framework }} --scope-config files/demo_cusp_config_plan.yml"
```

### VM Inventory Integration
VM demos use the existing inventory:
```yaml
- name: "Run VM demo"
  hosts: demo_vm  # From ansible_inventory
  become: false
```

## 🎯 Next Steps

1. **Test all demo types** to ensure they work correctly
2. **Update documentation** to reflect the new unified approach
3. **Consider adding more frameworks** using the same pattern
4. **Enhance error handling** in the demo runner script
5. **Add validation** for required files and dependencies

The improvements successfully address the original issue of unused configuration files while providing a more flexible and comprehensive demo experience.

