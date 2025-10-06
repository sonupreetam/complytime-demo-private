# ComplyTime Demo Ansible Playbooks

This directory contains comprehensive Ansible playbooks for setting up and running the ComplyTime demo environment.

## Available Playbooks

### 1. `setup_complete_demo.yml`
**Purpose**: Complete environment setup and configuration
**What it does**:
- Installs all required packages (Go, Ansible, OpenSCAP, SCAP Security Guide)
- Creates complyctl workspace directories
- Clones and builds complyctl from source
- Downloads OSCAL content (ANSSI BP28 minimal profile)
- Configures OpenSCAP plugin with manifest
- Generates initial assessment plan
- Sets up environment variables

### 2. `run_demo_commands.yml`
**Purpose**: Demonstrates complyctl functionality
**What it does**:
- Lists available compliance frameworks
- Shows detailed framework information
- Generates assessment plans
- Displays file structure and generated content
- Provides demo completion summary

### 3. `complytime_complete_demo.yml`
**Purpose**: Master playbook that runs everything
**What it does**:
- Runs the complete setup
- Executes all demo commands
- Provides comprehensive summary

### 4. `populate_complyctl_dev_content.yml` (Original)
**Purpose**: Downloads OSCAL content from upstream
**What it does**:
- Downloads OSCAL catalog, profile, and component definition
- Updates file references for local use

## Usage

### Option 1: Use the automated script
```bash
# From the project root directory
./run_demo.sh
```

### Option 2: Run playbooks manually

#### Inside the container:
```bash
# Connect to container
docker exec -it complytime-fedora-demo bash

# Navigate to playbooks
cd /tmp/base_ansible_env

# Run complete demo
ansible-playbook complytime_complete_demo.yml

# Or run individual playbooks
ansible-playbook setup_complete_demo.yml
ansible-playbook run_demo_commands.yml
```

#### From host system:
```bash
# Run setup only
ansible-playbook -i ansible_inventory setup_complete_demo.yml

# Run demo commands only
ansible-playbook -i ansible_inventory run_demo_commands.yml

# Run everything
ansible-playbook -i ansible_inventory complytime_complete_demo.yml
```

## Configuration

### Variables
Key variables you can customize in the playbooks:

```yaml
demo_framework: "anssi_bp28_minimal"  # Framework to use for demo
complyctl_workspace: "~/.local/share/complytime"  # Workspace location

# OSCAL content URLs (ANSSI BP28 minimal profile)
catalog: "https://github.com/ComplianceAsCode/oscal-content/raw/refs/heads/main/catalogs/anssi/catalog.json"
profile: "https://github.com/ComplianceAsCode/oscal-content/raw/refs/heads/main/profiles/rhel9-anssi-minimal/profile.json"
component_definition: "https://github.com/ComplianceAsCode/oscal-content/raw/refs/heads/main/component-definitions/rhel9/rhel9-anssi-minimal/component-definition.json"
```

### Inventory
The playbooks are configured to run on `localhost` with `ansible_connection: local`. For remote execution, update the inventory file:

```ini
[demo_vm]
your-target-host ansible_host=your-ip ansible_user=your-user ansible_ssh_pass=your-password
```

## Generated Files

After running the playbooks, you'll have:

```
complytime/
└── assessment-plan.json          # Generated assessment plan

~/.local/share/complytime/
├── controls/
│   ├── test-catalog.json         # OSCAL catalog
│   └── test-profile.json         # OSCAL profile
├── bundles/
│   └── test-component-definition.json  # OSCAL component definition
└── plugins/
    ├── openscap-plugin           # OpenSCAP plugin binary
    └── c2p-openscap-manifest.json  # Plugin manifest
```

## Demo Commands

After setup, you can run these commands:

```bash
# List available frameworks
complyctl list

# Get framework details
complyctl info anssi_bp28_minimal

# Generate assessment plan
complyctl plan anssi_bp28_minimal

# Generate policy files
complyctl generate

# Run compliance scan
complyctl scan

# Show workspace structure
tree -a
```

## Troubleshooting

### Common Issues

1. **Container not starting**: Check Docker/OrbStack is running
2. **Package installation fails**: Ensure container has internet access
3. **Plugin not found**: Verify manifest file is created correctly
4. **Permission denied**: Check file permissions in workspace

### Debug Mode

Run playbooks with verbose output:
```bash
ansible-playbook -vvv setup_complete_demo.yml
```

### Manual Verification

Check individual components:
```bash
# Verify complyctl is installed
complyctl version

# Check workspace structure
ls -la ~/.local/share/complytime/

# Verify plugin
ls -la ~/.local/share/complytime/plugins/
```

## Customization

### Adding New Frameworks

1. Update the OSCAL content URLs in the playbook variables
2. Modify the `demo_framework` variable
3. Run the setup playbook again

### Different Compliance Standards

The playbooks are designed to work with any OSCAL-compliant content. Simply update the URLs to point to different compliance frameworks.

### Integration with CI/CD

These playbooks can be integrated into CI/CD pipelines for automated compliance testing and reporting.


