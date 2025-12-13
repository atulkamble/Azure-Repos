#!/bin/bash

# Test Setup Script
# Verifies that Git and Azure DevOps tools are properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_header() { echo -e "${BLUE}[INFO]${NC} $1"; }

echo "🧪 Testing Git and Azure DevOps Setup"
echo "====================================="

# Test Git installation
print_header "Testing Git installation..."
if command -v git &> /dev/null; then
    git_version=$(git --version)
    print_status "Git is installed: $git_version"
else
    print_error "Git is not installed"
    exit 1
fi

# Test Git configuration
print_header "Testing Git configuration..."
if git config --global user.name &> /dev/null; then
    user_name=$(git config --global user.name)
    print_status "Git user name: $user_name"
else
    print_warning "Git user name not configured"
fi

if git config --global user.email &> /dev/null; then
    user_email=$(git config --global user.email)
    print_status "Git user email: $user_email"
else
    print_warning "Git user email not configured"
fi

# Test Git repository
print_header "Testing Git repository..."
if git rev-parse --git-dir &> /dev/null; then
    print_status "Currently in a Git repository"
    
    # Test remote
    if git remote -v &> /dev/null; then
        remote_info=$(git remote -v | head -1)
        print_status "Remote configured: $remote_info"
    else
        print_warning "No remote configured"
    fi
    
    # Test branch
    current_branch=$(git branch --show-current)
    print_status "Current branch: $current_branch"
else
    print_warning "Not in a Git repository (this is expected for initial setup)"
fi

# Test Python installation
print_header "Testing Python installation..."
if command -v python3 &> /dev/null; then
    python_version=$(python3 --version)
    print_status "Python is installed: $python_version"
    
    # Test example project
    if [ -f "examples/simple-project/src/main.py" ]; then
        print_status "Simple project example found"
        cd examples/simple-project
        
        if python3 src/main.py &> /dev/null; then
            print_status "Simple project runs successfully"
        else
            print_warning "Simple project has execution issues"
        fi
        
        cd - > /dev/null
    fi
else
    print_warning "Python 3 is not installed"
fi

# Test Azure CLI
print_header "Testing Azure CLI..."
if command -v az &> /dev/null; then
    az_version=$(az --version | head -1)
    print_status "Azure CLI is installed: $az_version"
    
    # Test authentication
    if az account show &> /dev/null; then
        account_info=$(az account show --query "name" -o tsv)
        print_status "Azure CLI authenticated: $account_info"
    else
        print_warning "Azure CLI not authenticated (run 'az login')"
    fi
else
    print_warning "Azure CLI is not installed"
fi

# Test GitHub CLI
print_header "Testing GitHub CLI..."
if command -v gh &> /dev/null; then
    gh_version=$(gh --version | head -1)
    print_status "GitHub CLI is installed: $gh_version"
    
    # Test authentication
    if gh auth status &> /dev/null; then
        print_status "GitHub CLI is authenticated"
    else
        print_warning "GitHub CLI not authenticated (run 'gh auth login')"
    fi
else
    print_warning "GitHub CLI is not installed"
fi

# Test Node.js (optional)
print_header "Testing Node.js (optional)..."
if command -v node &> /dev/null; then
    node_version=$(node --version)
    print_status "Node.js is installed: $node_version"
else
    print_warning "Node.js is not installed (optional for web projects)"
fi

# Test Docker (optional)
print_header "Testing Docker (optional)..."
if command -v docker &> /dev/null; then
    if docker --version &> /dev/null; then
        docker_version=$(docker --version)
        print_status "Docker is installed: $docker_version"
    else
        print_warning "Docker is installed but not running"
    fi
else
    print_warning "Docker is not installed (optional for containerization)"
fi

# Test script permissions
print_header "Testing script permissions..."
script_dir="scripts"
if [ -d "$script_dir" ]; then
    executable_count=0
    total_scripts=0
    
    for script in "$script_dir"/*.sh; do
        if [ -f "$script" ]; then
            total_scripts=$((total_scripts + 1))
            if [ -x "$script" ]; then
                executable_count=$((executable_count + 1))
            fi
        fi
    done
    
    if [ $executable_count -eq $total_scripts ] && [ $total_scripts -gt 0 ]; then
        print_status "All $total_scripts shell scripts are executable"
    else
        print_warning "$executable_count of $total_scripts scripts are executable"
        print_warning "Run: chmod +x scripts/*.sh"
    fi
else
    print_warning "Scripts directory not found"
fi

# Test file structure
print_header "Testing file structure..."
required_dirs=("src" "scripts" "templates" "docs" "examples")
missing_dirs=()

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_status "Directory exists: $dir"
    else
        missing_dirs+=("$dir")
        print_error "Missing directory: $dir"
    fi
done

# Summary
echo ""
print_header "🎯 Setup Test Summary"
echo "===================="

if [ ${#missing_dirs[@]} -eq 0 ]; then
    print_status "All required directories exist"
    print_status "✅ Setup verification completed successfully!"
    
    echo ""
    print_header "🚀 Next Steps:"
    echo "1. Run: ./scripts/setup-git-credentials.sh (if Git not configured)"
    echo "2. Explore examples: cd examples/simple-project"
    echo "3. Read documentation: docs/"
    echo "4. Start your Git workflow!"
else
    print_error "❌ Setup verification found issues"
    echo "Missing directories: ${missing_dirs[*]}"
    echo "Please ensure all required files and directories are present"
    exit 1
fi

echo ""
print_header "📚 Useful Resources:"
echo "- README.md - Main documentation"
echo "- docs/troubleshooting.md - Common issues and solutions"  
echo "- docs/best-practices.md - Git and Azure DevOps best practices"
echo "- scripts/ - Automation scripts"
echo "- examples/ - Working examples"

echo ""
print_status "Happy coding! 🎉"