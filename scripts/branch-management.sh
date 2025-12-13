#!/bin/bash

# Branch Management Utilities for Git and Azure DevOps
# Provides utilities for creating, managing, and syncing branches

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Configuration
DEFAULT_REMOTE="origin"
DEFAULT_BASE_BRANCH="main"

show_usage() {
    cat << EOF
Branch Management Utilities
Usage: $0 COMMAND [OPTIONS]

COMMANDS:
    create BRANCH_NAME [BASE]     Create a new branch from BASE (default: main)
    switch BRANCH_NAME            Switch to existing branch
    delete BRANCH_NAME            Delete branch (local and remote)
    list                          List all branches
    sync                          Sync current branch with remote
    cleanup                       Clean up merged branches
    status                        Show branch status
    merge BRANCH_NAME             Merge branch into current branch
    rebase BRANCH_NAME [BASE]     Rebase branch onto BASE
    push [BRANCH_NAME]            Push branch to remote
    pull [BRANCH_NAME]            Pull branch from remote

OPTIONS:
    -r, --remote REMOTE           Specify remote (default: origin)
    -b, --base BRANCH             Specify base branch (default: main)
    -f, --force                   Force operation
    -d, --dry-run                 Show what would be done
    -h, --help                    Show this help

EXAMPLES:
    $0 create feature/user-auth
    $0 create hotfix/bug-fix main
    $0 switch feature/user-auth
    $0 delete feature/completed
    $0 cleanup
    $0 sync
EOF
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Get current branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Check if branch exists locally
branch_exists_local() {
    git show-ref --verify --quiet refs/heads/"$1"
}

# Check if branch exists on remote
branch_exists_remote() {
    git show-ref --verify --quiet refs/remotes/"$DEFAULT_REMOTE"/"$1"
}

# Create new branch
create_branch() {
    local branch_name="$1"
    local base_branch="${2:-$DEFAULT_BASE_BRANCH}"
    
    if [[ -z "$branch_name" ]]; then
        print_error "Branch name required"
        exit 1
    fi
    
    print_header "Creating branch '$branch_name' from '$base_branch'"
    
    # Check if branch already exists
    if branch_exists_local "$branch_name"; then
        print_error "Branch '$branch_name' already exists locally"
        exit 1
    fi
    
    # Fetch latest changes
    print_status "Fetching latest changes..."
    git fetch "$DEFAULT_REMOTE"
    
    # Create and switch to new branch
    if branch_exists_remote "$base_branch"; then
        git checkout -b "$branch_name" "$DEFAULT_REMOTE/$base_branch"
    else
        git checkout -b "$branch_name" "$base_branch"
    fi
    
    print_status "Created and switched to branch '$branch_name'"
    
    # Ask if user wants to push to remote
    read -p "Push branch to remote? (y/n): " push_branch
    if [[ $push_branch == "y" || $push_branch == "Y" ]]; then
        git push -u "$DEFAULT_REMOTE" "$branch_name"
        print_status "Branch pushed to remote with upstream tracking"
    fi
}

# Switch to existing branch
switch_branch() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        print_error "Branch name required"
        exit 1
    fi
    
    print_header "Switching to branch '$branch_name'"
    
    # Check if branch exists locally
    if branch_exists_local "$branch_name"; then
        git checkout "$branch_name"
        print_status "Switched to local branch '$branch_name'"
    elif branch_exists_remote "$branch_name"; then
        git checkout -b "$branch_name" "$DEFAULT_REMOTE/$branch_name"
        print_status "Created local branch '$branch_name' from remote"
    else
        print_error "Branch '$branch_name' not found locally or on remote"
        print_status "Available branches:"
        git branch -a
        exit 1
    fi
}

# Delete branch
delete_branch() {
    local branch_name="$1"
    local force_delete="${2:-false}"
    
    if [[ -z "$branch_name" ]]; then
        print_error "Branch name required"
        exit 1
    fi
    
    local current_branch=$(get_current_branch)
    if [[ "$current_branch" == "$branch_name" ]]; then
        print_error "Cannot delete current branch. Switch to another branch first."
        exit 1
    fi
    
    print_header "Deleting branch '$branch_name'"
    
    # Delete local branch
    if branch_exists_local "$branch_name"; then
        if [[ "$force_delete" == "true" ]]; then
            git branch -D "$branch_name"
        else
            git branch -d "$branch_name"
        fi
        print_status "Deleted local branch '$branch_name'"
    fi
    
    # Delete remote branch
    if branch_exists_remote "$branch_name"; then
        read -p "Delete remote branch? (y/n): " delete_remote
        if [[ $delete_remote == "y" || $delete_remote == "Y" ]]; then
            git push "$DEFAULT_REMOTE" --delete "$branch_name"
            print_status "Deleted remote branch '$branch_name'"
        fi
    fi
}

# List branches
list_branches() {
    print_header "Branch Overview"
    
    local current_branch=$(get_current_branch)
    
    echo "Current branch: $current_branch"
    echo ""
    
    print_status "Local branches:"
    git branch -v
    
    echo ""
    print_status "Remote branches:"
    git branch -r -v
    
    echo ""
    print_status "Branch tracking information:"
    for branch in $(git branch --format='%(refname:short)'); do
        if [[ "$branch" != "$current_branch" ]]; then
            upstream=$(git rev-parse --abbrev-ref "$branch"@{upstream} 2>/dev/null || echo "no upstream")
            echo "  $branch -> $upstream"
        fi
    done
}

# Sync current branch with remote
sync_branch() {
    local current_branch=$(get_current_branch)
    
    print_header "Syncing branch '$current_branch'"
    
    # Check if branch has upstream
    if ! git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
        print_warning "No upstream branch set for '$current_branch'"
        read -p "Set upstream to $DEFAULT_REMOTE/$current_branch? (y/n): " set_upstream
        if [[ $set_upstream == "y" || $set_upstream == "Y" ]]; then
            git push -u "$DEFAULT_REMOTE" "$current_branch"
            print_status "Upstream set to $DEFAULT_REMOTE/$current_branch"
        fi
        return
    fi
    
    # Fetch and check status
    git fetch "$DEFAULT_REMOTE"
    
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse @{upstream})
    local base_commit=$(git merge-base HEAD @{upstream})
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        print_status "Branch is up to date"
    elif [[ "$local_commit" == "$base_commit" ]]; then
        print_status "Branch is behind remote. Pulling changes..."
        git pull
    elif [[ "$remote_commit" == "$base_commit" ]]; then
        print_status "Branch is ahead of remote"
        read -p "Push changes? (y/n): " push_changes
        if [[ $push_changes == "y" || $push_changes == "Y" ]]; then
            git push
        fi
    else
        print_warning "Branch has diverged from remote"
        echo "Options:"
        echo "1. Pull and merge"
        echo "2. Pull and rebase"
        echo "3. Force push (dangerous)"
        echo "4. Do nothing"
        
        read -p "Choose option (1-4): " sync_option
        case $sync_option in
            1)
                git pull
                ;;
            2)
                git pull --rebase
                ;;
            3)
                read -p "Are you sure? This will overwrite remote history! (yes/no): " confirm
                if [[ $confirm == "yes" ]]; then
                    git push --force-with-lease
                fi
                ;;
            4)
                print_status "No changes made"
                ;;
        esac
    fi
}

# Clean up merged branches
cleanup_branches() {
    print_header "Cleaning up merged branches"
    
    # Get merged branches (excluding current and main branches)
    local current_branch=$(get_current_branch)
    local merged_branches=$(git branch --merged | grep -v "^\*\|$DEFAULT_BASE_BRANCH\|main\|master\|develop" | xargs)
    
    if [[ -z "$merged_branches" ]]; then
        print_status "No merged branches to clean up"
        return
    fi
    
    print_status "Merged branches found:"
    echo "$merged_branches"
    
    read -p "Delete these branches? (y/n): " delete_merged
    if [[ $delete_merged == "y" || $delete_merged == "Y" ]]; then
        echo "$merged_branches" | xargs git branch -d
        print_status "Cleaned up merged branches"
    fi
    
    # Clean up remote tracking branches
    print_status "Cleaning up remote tracking branches..."
    git remote prune "$DEFAULT_REMOTE"
}

# Show branch status
show_status() {
    print_header "Branch Status"
    
    local current_branch=$(get_current_branch)
    echo "Current branch: $current_branch"
    
    # Show uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "Uncommitted changes:"
        git status --porcelain
    else
        print_status "Working directory is clean"
    fi
    
    # Show commit difference with remote
    if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
        local ahead=$(git rev-list --count @{upstream}..HEAD)
        local behind=$(git rev-list --count HEAD..@{upstream})
        
        if [[ $ahead -gt 0 ]]; then
            print_status "Ahead of remote by $ahead commit(s)"
        fi
        
        if [[ $behind -gt 0 ]]; then
            print_status "Behind remote by $behind commit(s)"
        fi
        
        if [[ $ahead -eq 0 && $behind -eq 0 ]]; then
            print_status "In sync with remote"
        fi
    else
        print_warning "No upstream branch configured"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--remote)
            DEFAULT_REMOTE="$2"
            shift 2
            ;;
        -b|--base)
            DEFAULT_BASE_BRANCH="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_FLAG="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        create|switch|delete|list|sync|cleanup|status|merge|rebase|push|pull)
            COMMAND="$1"
            shift
            break
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
check_git_repo

# Execute command
case "${COMMAND:-help}" in
    create)
        create_branch "$1" "$2"
        ;;
    switch)
        switch_branch "$1"
        ;;
    delete)
        delete_branch "$1" "$FORCE_FLAG"
        ;;
    list)
        list_branches
        ;;
    sync)
        sync_branch
        ;;
    cleanup)
        cleanup_branches
        ;;
    status)
        show_status
        ;;
    push)
        branch_name="${1:-$(get_current_branch)}"
        git push "$DEFAULT_REMOTE" "$branch_name"
        ;;
    pull)
        branch_name="${1:-$(get_current_branch)}"
        git pull "$DEFAULT_REMOTE" "$branch_name"
        ;;
    help)
        show_usage
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac