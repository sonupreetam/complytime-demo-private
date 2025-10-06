#!/bin/bash

# Test script for EnsureUserWorkspace permission scenarios
# This script demonstrates various permission denied error cases

set -e

echo "=== Testing Permission Denied Scenarios for EnsureUserWorkspace ==="

# Cleanup function
cleanup() {
    echo "Cleaning up test directories..."
    rm -rf /tmp/test-workspace-scenarios
    echo "Cleanup complete."
}
trap cleanup EXIT

# Setup test environment
TEST_BASE="/tmp/test-workspace-scenarios"
mkdir -p "$TEST_BASE"
cd "$TEST_BASE"

echo -e "\n1. Testing: Parent directory is read-only"
echo "Setup: Create read-only parent directory"
mkdir -p readonly-parent
chmod 555 readonly-parent
echo "Attempting to create workspace in read-only parent..."
echo "Expected: mkdir: permission denied"
echo "Command: mkdir readonly-parent/complytime"
mkdir readonly-parent/complytime 2>&1 || echo "✓ Got expected permission denied error"

echo -e "\n2. Testing: Directory exists but is read-only"
echo "Setup: Create directory and make it read-only"
mkdir -p existing-readonly
chmod 444 existing-readonly
echo "Attempting to write to read-only directory..."
echo "Expected: permission denied when trying to create files inside"
echo "Command: touch existing-readonly/test-file"
touch existing-readonly/test-file 2>&1 || echo "✓ Got expected permission denied error"

echo -e "\n3. Testing: File exists at target path"
echo "Setup: Create file at target location"
touch file-at-workspace-path
echo "Attempting to create directory where file exists..."
echo "Expected: mkdir: not a directory or file exists"
echo "Command: mkdir file-at-workspace-path"
mkdir file-at-workspace-path 2>&1 || echo "✓ Got expected error (file exists)"

echo -e "\n4. Testing: Deep nested path with permission issues"
echo "Setup: Create nested structure with permission restrictions"
mkdir -p deep/nested/path
chmod 000 deep/nested  # No permissions at all
echo "Attempting to create directory in restricted nested path..."
echo "Expected: permission denied"
echo "Command: mkdir deep/nested/path/workspace"
mkdir deep/nested/path/workspace 2>&1 || echo "✓ Got expected permission denied error"

echo -e "\n5. Testing: Insufficient permissions on existing directory"
echo "Setup: Create directory with minimal permissions"
mkdir -p limited-perms
chmod 100 limited-perms  # Execute only, no read/write
echo "Attempting to access directory with limited permissions..."
echo "Expected: permission denied"
echo "Command: ls limited-perms"
ls limited-perms 2>&1 || echo "✓ Got expected permission denied error"

echo -e "\n=== Permission Scenario Tests Complete ==="
echo "These are the types of errors EnsureUserWorkspace should handle gracefully."
