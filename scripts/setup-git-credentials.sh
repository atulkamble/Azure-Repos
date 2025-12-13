#!/bin/bash

# Git Credential Setup Script for Multiple Platforms
# This script configures Git credentials across different operating systems

set -e

echo "🔧 Git Credential Setup Script"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    echo "Download from: https://git-scm.com/downloads"
    exit 1
fi

print_status "Git version: $(git --version)"

# Detect operating system
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

print_status "Detected OS: $OS"

# Function to setup Git user configuration
setup_git_user() {
    print_header "Setting up Git user configuration"
    
    # Check if user.name is already set
    if git config --global user.name >/dev/null 2>&1; then
        current_name=$(git config --global user.name)
        print_status "Current Git user name: $current_name"
        read -p "Do you want to change it? (y/n): " change_name
        if [[ $change_name == "y" || $change_name == "Y" ]]; then
            read -p "Enter your full name: " user_name
            git config --global user.name "$user_name"
        fi
    else
        read -p "Enter your full name: " user_name
        git config --global user.name "$user_name"
    fi
    
    # Check if user.email is already set
    if git config --global user.email >/dev/null 2>&1; then
        current_email=$(git config --global user.email)
        print_status "Current Git user email: $current_email"
        read -p "Do you want to change it? (y/n): " change_email
        if [[ $change_email == "y" || $change_email == "Y" ]]; then
            read -p "Enter your email: " user_email
            git config --global user.email "$user_email"
        fi
    else
        read -p "Enter your email: " user_email
        git config --global user.email "$user_email"
    fi
    
    print_status "Git user configuration completed"
}

# Function to setup credential helper
setup_credential_helper() {
    print_header "Setting up Git credential helper"
    
    case $OS in
        "windows")
            print_status "Setting up Git Credential Manager for Windows"
            git config --global credential.helper manager-core
            ;;
        "mac")
            print_status "Setting up Git credential helper for macOS"
            git config --global credential.helper osxkeychain
            ;;
        "linux")
            print_status "Setting up Git credential helper for Linux"
            # Check if libsecret is available
            if command -v git-credential-libsecret &> /dev/null; then
                git config --global credential.helper libsecret
                print_status "Using libsecret credential helper"
            else
                print_warning "libsecret not found, using store helper"
                git config --global credential.helper store
                print_warning "Credentials will be stored in plain text in ~/.git-credentials"
            fi
            ;;
        *)
            print_warning "Unknown OS, using default store helper"
            git config --global credential.helper store
            ;;
    esac
}

# Function to setup useful Git aliases
setup_git_aliases() {
    print_header "Setting up useful Git aliases"
    
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.up 'pull --rebase'
    git config --global alias.lg "log --oneline --graph --decorate --all"
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    
    print_status "Git aliases configured:"
    echo "  - git st     = git status"
    echo "  - git co     = git checkout"
    echo "  - git br     = git branch"
    echo "  - git ci     = git commit"
    echo "  - git up     = git pull --rebase"
    echo "  - git lg     = git log --oneline --graph --decorate --all"
    echo "  - git unstage= git reset HEAD --"
    echo "  - git last   = git log -1 HEAD"
}

# Function to setup other useful Git configurations
setup_git_config() {
    print_header "Setting up additional Git configurations"
    
    # Set default branch name to main
    git config --global init.defaultBranch main
    
    # Enable helpful colorization
    git config --global color.ui auto
    
    # Configure line ending handling
    if [[ "$OS" == "windows" ]]; then
        git config --global core.autocrlf true
    else
        git config --global core.autocrlf input
    fi
    
    # Configure push behavior
    git config --global push.default simple
    
    # Configure pull behavior
    git config --global pull.rebase false
    
    print_status "Additional Git configurations applied"
}

# Function to setup Azure DevOps specific configuration
setup_azure_devops() {
    print_header "Azure DevOps Configuration (Optional)"
    
    read -p "Do you want to configure Azure DevOps settings? (y/n): " setup_azure
    if [[ $setup_azure == "y" || $setup_azure == "Y" ]]; then
        read -p "Enter your Azure DevOps organization: " azure_org
        read -p "Enter your Azure DevOps project: " azure_project
        
        # Store in global Git config for reference
        git config --global azure.organization "$azure_org"
        git config --global azure.project "$azure_project"
        
        print_status "Azure DevOps configuration saved"
        echo "Organization: $azure_org"
        echo "Project: $azure_project"
        
        print_status "To clone Azure DevOps repositories, use:"
        echo "git clone https://dev.azure.com/$azure_org/$azure_project/_git/<repo-name>"
    fi
}

# Function to test Git configuration
test_configuration() {
    print_header "Testing Git configuration"
    
    echo "Current Git configuration:"
    echo "------------------------"
    echo "User Name: $(git config --global user.name)"
    echo "User Email: $(git config --global user.email)"
    echo "Credential Helper: $(git config --global credential.helper)"
    echo "Default Branch: $(git config --global init.defaultBranch)"
    
    # Test if we can create a test repository
    test_dir="/tmp/git-test-$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    print_status "Creating test repository..."
    git init
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    print_status "Test repository created successfully!"
    
    cd - > /dev/null
    rm -rf "$test_dir"
}

# Main execution
main() {
    print_header "Starting Git credential setup"
    
    setup_git_user
    setup_credential_helper
    setup_git_aliases
    setup_git_config
    setup_azure_devops
    test_configuration
    
    print_status "🎉 Git credential setup completed successfully!"
    print_status "You can now clone repositories and Git will handle authentication automatically."
    
    echo ""
    print_status "Next steps:"
    echo "1. Clone your Azure DevOps repository"
    echo "2. Start working with Git commands"
    echo "3. Use the provided aliases for faster workflows"
    echo ""
    print_status "For troubleshooting, check: git config --list --global"
}

# Run main function
main "$@"