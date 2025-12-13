#!/bin/bash

# Azure Repository Cloning Script
# Batch clone multiple Azure DevOps repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Configuration
AZURE_ORG=""
AZURE_PROJECT=""
REPOS_FILE="repos.txt"
CLONE_DIR="./cloned-repos"
PROTOCOL="https" # https or ssh

# Function to show usage
show_usage() {
    cat << EOF
Azure Repository Cloning Script
Usage: $0 [OPTIONS]

OPTIONS:
    -o, --org ORGANIZATION     Azure DevOps organization name
    -p, --project PROJECT      Azure DevOps project name
    -f, --file FILE           File containing repository names (one per line)
    -d, --dir DIRECTORY       Directory to clone repositories into
    -s, --ssh                 Use SSH instead of HTTPS
    -h, --help                Show this help message

EXAMPLES:
    $0 -o myorg -p myproject -f repos.txt
    $0 --org myorg --project myproject --ssh
    $0 -o myorg -p myproject -d /path/to/repos

REPOSITORY FILE FORMAT (repos.txt):
    repo1
    repo2
    repo3
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--org)
            AZURE_ORG="$2"
            shift 2
            ;;
        -p|--project)
            AZURE_PROJECT="$2"
            shift 2
            ;;
        -f|--file)
            REPOS_FILE="$2"
            shift 2
            ;;
        -d|--dir)
            CLONE_DIR="$2"
            shift 2
            ;;
        -s|--ssh)
            PROTOCOL="ssh"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validation
if [[ -z "$AZURE_ORG" ]]; then
    # Try to get from git config
    AZURE_ORG=$(git config --global azure.organization 2>/dev/null || echo "")
    if [[ -z "$AZURE_ORG" ]]; then
        print_error "Azure organization not specified. Use -o option or configure with git config --global azure.organization <org>"
        exit 1
    fi
fi

if [[ -z "$AZURE_PROJECT" ]]; then
    # Try to get from git config
    AZURE_PROJECT=$(git config --global azure.project 2>/dev/null || echo "")
    if [[ -z "$AZURE_PROJECT" ]]; then
        print_error "Azure project not specified. Use -p option or configure with git config --global azure.project <project>"
        exit 1
    fi
fi

print_status "Configuration:"
print_status "Organization: $AZURE_ORG"
print_status "Project: $AZURE_PROJECT"
print_status "Protocol: $PROTOCOL"
print_status "Clone Directory: $CLONE_DIR"

# Function to construct repository URL
get_repo_url() {
    local repo_name="$1"
    if [[ "$PROTOCOL" == "ssh" ]]; then
        echo "git@ssh.dev.azure.com:v3/$AZURE_ORG/$AZURE_PROJECT/$repo_name"
    else
        echo "https://dev.azure.com/$AZURE_ORG/$AZURE_PROJECT/_git/$repo_name"
    fi
}

# Function to clone a single repository
clone_repository() {
    local repo_name="$1"
    local repo_url=$(get_repo_url "$repo_name")
    local target_dir="$CLONE_DIR/$repo_name"
    
    print_header "Cloning $repo_name"
    
    if [[ -d "$target_dir" ]]; then
        print_warning "Directory $target_dir already exists. Skipping..."
        return 0
    fi
    
    if git clone "$repo_url" "$target_dir"; then
        print_status "Successfully cloned $repo_name"
        
        # Set up additional remotes if needed
        cd "$target_dir"
        
        # Add upstream remote if this is a fork
        read -p "Is $repo_name a fork? Add upstream remote? (y/n): " is_fork
        if [[ $is_fork == "y" || $is_fork == "Y" ]]; then
            read -p "Enter upstream repository name: " upstream_repo
            upstream_url=$(get_repo_url "$upstream_repo")
            git remote add upstream "$upstream_url"
            print_status "Added upstream remote for $upstream_repo"
        fi
        
        cd - > /dev/null
        return 0
    else
        print_error "Failed to clone $repo_name"
        return 1
    fi
}

# Function to list Azure DevOps repositories (requires Azure CLI)
list_azure_repos() {
    print_header "Listing available repositories"
    
    if ! command -v az &> /dev/null; then
        print_warning "Azure CLI not found. Cannot list repositories automatically."
        print_status "Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        return 1
    fi
    
    print_status "Fetching repository list from Azure DevOps..."
    az repos list --organization "https://dev.azure.com/$AZURE_ORG" --project "$AZURE_PROJECT" --query "[].name" -o tsv > available_repos.txt
    
    if [[ $? -eq 0 ]]; then
        print_status "Available repositories saved to available_repos.txt:"
        cat available_repos.txt
        
        read -p "Use this list for cloning? (y/n): " use_list
        if [[ $use_list == "y" || $use_list == "Y" ]]; then
            REPOS_FILE="available_repos.txt"
        fi
    else
        print_error "Failed to fetch repository list. Make sure you're logged in with 'az login'"
    fi
}

# Function to create repository list interactively
create_repo_list() {
    print_header "Creating repository list interactively"
    
    echo "Enter repository names (one per line, empty line to finish):"
    > "$REPOS_FILE"
    
    while true; do
        read -p "Repository name: " repo_name
        if [[ -z "$repo_name" ]]; then
            break
        fi
        echo "$repo_name" >> "$REPOS_FILE"
    done
    
    print_status "Repository list saved to $REPOS_FILE"
}

# Function to clone all repositories
clone_all_repositories() {
    local success_count=0
    local fail_count=0
    local total_count=0
    
    # Create clone directory
    mkdir -p "$CLONE_DIR"
    
    print_header "Starting batch clone operation"
    
    while IFS= read -r repo_name; do
        # Skip empty lines and comments
        [[ -z "$repo_name" || "$repo_name" =~ ^#.*$ ]] && continue
        
        ((total_count++))
        
        if clone_repository "$repo_name"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        
        echo ""
    done < "$REPOS_FILE"
    
    print_header "Clone operation completed"
    print_status "Total repositories: $total_count"
    print_status "Successful: $success_count"
    print_status "Failed: $fail_count"
    
    if [[ $fail_count -gt 0 ]]; then
        print_warning "Some repositories failed to clone. Check the error messages above."
    fi
}

# Function to update all cloned repositories
update_all_repositories() {
    print_header "Updating all cloned repositories"
    
    if [[ ! -d "$CLONE_DIR" ]]; then
        print_error "Clone directory $CLONE_DIR does not exist"
        return 1
    fi
    
    for repo_dir in "$CLONE_DIR"/*; do
        if [[ -d "$repo_dir/.git" ]]; then
            repo_name=$(basename "$repo_dir")
            print_status "Updating $repo_name"
            
            cd "$repo_dir"
            git fetch --all
            git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || print_warning "Could not pull $repo_name"
            cd - > /dev/null
        fi
    done
    
    print_status "All repositories updated"
}

# Main function
main() {
    print_header "Azure Repository Cloning Script"
    
    # Check if repos file exists
    if [[ ! -f "$REPOS_FILE" ]]; then
        print_warning "Repository list file $REPOS_FILE not found"
        
        # Offer options
        echo "Options:"
        echo "1. List repositories from Azure DevOps (requires Azure CLI)"
        echo "2. Create repository list interactively"
        echo "3. Exit"
        
        read -p "Choose an option (1-3): " option
        
        case $option in
            1)
                list_azure_repos
                ;;
            2)
                create_repo_list
                ;;
            3)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    fi
    
    # Check if this is an update operation
    if [[ -d "$CLONE_DIR" ]]; then
        echo "Clone directory already exists."
        echo "1. Clone new repositories"
        echo "2. Update existing repositories"
        echo "3. Both"
        
        read -p "Choose an option (1-3): " update_option
        
        case $update_option in
            1)
                clone_all_repositories
                ;;
            2)
                update_all_repositories
                ;;
            3)
                clone_all_repositories
                update_all_repositories
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    else
        clone_all_repositories
    fi
    
    print_status "🎉 Operation completed!"
}

# Run main function
main "$@"