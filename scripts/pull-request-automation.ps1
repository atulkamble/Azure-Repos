# PowerShell Script for Pull Request Automation
# Supports both GitHub and Azure DevOps

param(
    [Parameter(Mandatory=$false)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$Description,
    
    [Parameter(Mandatory=$false)]
    [string]$SourceBranch,
    
    [Parameter(Mandatory=$false)]
    [string]$TargetBranch = "main",
    
    [Parameter(Mandatory=$false)]
    [string]$Platform = "auto",  # auto, github, azuredevops
    
    [Parameter(Mandatory=$false)]
    [string[]]$Reviewers = @(),
    
    [Parameter(Mandatory=$false)]
    [string[]]$Labels = @(),
    
    [Parameter(Mandatory=$false)]
    [switch]$Draft = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoComplete = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Colors for output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue
$White = [System.ConsoleColor]::White

function Write-ColorOutput($Message, $Color = $White) {
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Write-Info($Message) { Write-ColorOutput "[INFO] $Message" $Green }
function Write-Warning($Message) { Write-ColorOutput "[WARN] $Message" $Yellow }
function Write-Error($Message) { Write-ColorOutput "[ERROR] $Message" $Red }
function Write-Header($Message) { Write-ColorOutput "[STEP] $Message" $Blue }

function Show-Usage {
    Write-Output @"
Pull Request Automation Script
Usage: .\pull-request-automation.ps1 [OPTIONS]

OPTIONS:
    -Title TITLE                  Pull request title
    -Description DESCRIPTION      Pull request description
    -SourceBranch BRANCH         Source branch (default: current branch)
    -TargetBranch BRANCH         Target branch (default: main)
    -Platform PLATFORM           Platform: auto, github, azuredevops (default: auto)
    -Reviewers REVIEWERS         Array of reviewer usernames/emails
    -Labels LABELS               Array of labels to add
    -Draft                       Create as draft pull request
    -AutoComplete               Enable auto-complete (Azure DevOps only)
    -Help                        Show this help message

EXAMPLES:
    .\pull-request-automation.ps1 -Title "Add user authentication" -Description "Implements OAuth2 login"
    .\pull-request-automation.ps1 -Title "Bug fix" -SourceBranch "hotfix/login" -Reviewers @("user1", "user2")
    .\pull-request-automation.ps1 -Platform "github" -Draft
"@
}

function Test-GitRepository {
    try {
        git rev-parse --git-dir | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-CurrentBranch {
    try {
        return git rev-parse --abbrev-ref HEAD
    }
    catch {
        throw "Failed to get current branch"
    }
}

function Get-RepositoryInfo {
    $remoteUrl = git remote get-url origin
    
    if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/.]+)") {
        return @{
            Platform = "github"
            Owner = $Matches[1]
            Repository = $Matches[2]
            Url = $remoteUrl
        }
    }
    elseif ($remoteUrl -match "dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+)") {
        return @{
            Platform = "azuredevops"
            Organization = $Matches[1]
            Project = $Matches[2]
            Repository = $Matches[3]
            Url = $remoteUrl
        }
    }
    elseif ($remoteUrl -match "([^/]+)\.visualstudio\.com/([^/]+)/_git/([^/]+)") {
        return @{
            Platform = "azuredevops"
            Organization = $Matches[1]
            Project = $Matches[2]
            Repository = $Matches[3]
            Url = $remoteUrl
        }
    }
    else {
        throw "Unsupported repository URL format: $remoteUrl"
    }
}

function Test-CommandExists($Command) {
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-PullRequestTemplate {
    param([string]$Platform)
    
    $templatePaths = @()
    
    if ($Platform -eq "github") {
        $templatePaths = @(
            ".github/pull_request_template.md",
            ".github/PULL_REQUEST_TEMPLATE.md",
            "docs/pull_request_template.md"
        )
    }
    elseif ($Platform -eq "azuredevops") {
        $templatePaths = @(
            ".azuredevops/pull_request_template.md",
            "docs/pull_request_template.md"
        )
    }
    
    foreach ($path in $templatePaths) {
        if (Test-Path $path) {
            return Get-Content $path -Raw
        }
    }
    
    return $null
}

function New-GitHubPullRequest {
    param(
        [hashtable]$RepoInfo,
        [string]$Title,
        [string]$Description,
        [string]$SourceBranch,
        [string]$TargetBranch,
        [string[]]$Reviewers,
        [string[]]$Labels,
        [bool]$Draft
    )
    
    if (-not (Test-CommandExists "gh")) {
        Write-Error "GitHub CLI (gh) is not installed. Install from: https://cli.github.com/"
        return $false
    }
    
    # Check if authenticated
    try {
        gh auth status | Out-Null
    }
    catch {
        Write-Warning "Not authenticated with GitHub. Running 'gh auth login'..."
        gh auth login
    }
    
    # Build command arguments
    $args = @(
        "pr", "create",
        "--title", $Title,
        "--body", $Description,
        "--base", $TargetBranch,
        "--head", $SourceBranch
    )
    
    if ($Draft) {
        $args += "--draft"
    }
    
    if ($Reviewers.Count -gt 0) {
        $args += "--reviewer"
        $args += ($Reviewers -join ",")
    }
    
    if ($Labels.Count -gt 0) {
        $args += "--label"
        $args += ($Labels -join ",")
    }
    
    try {
        Write-Info "Creating GitHub pull request..."
        $result = & gh @args
        Write-Info "GitHub pull request created successfully!"
        Write-Output $result
        return $true
    }
    catch {
        Write-Error "Failed to create GitHub pull request: $_"
        return $false
    }
}

function New-AzureDevOpsPullRequest {
    param(
        [hashtable]$RepoInfo,
        [string]$Title,
        [string]$Description,
        [string]$SourceBranch,
        [string]$TargetBranch,
        [string[]]$Reviewers,
        [bool]$Draft,
        [bool]$AutoComplete
    )
    
    if (-not (Test-CommandExists "az")) {
        Write-Error "Azure CLI is not installed. Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        return $false
    }
    
    # Check if authenticated
    try {
        az account show | Out-Null
    }
    catch {
        Write-Warning "Not authenticated with Azure. Running 'az login'..."
        az login
    }
    
    # Build command arguments
    $orgUrl = "https://dev.azure.com/$($RepoInfo.Organization)"
    
    $args = @(
        "repos", "pr", "create",
        "--organization", $orgUrl,
        "--project", $RepoInfo.Project,
        "--repository", $RepoInfo.Repository,
        "--title", $Title,
        "--description", $Description,
        "--source-branch", $SourceBranch,
        "--target-branch", $TargetBranch
    )
    
    if ($Draft) {
        $args += "--draft", "true"
    }
    
    if ($AutoComplete) {
        $args += "--auto-complete", "true"
    }
    
    if ($Reviewers.Count -gt 0) {
        $args += "--reviewers"
        $args += ($Reviewers -join " ")
    }
    
    try {
        Write-Info "Creating Azure DevOps pull request..."
        $result = & az @args --output json | ConvertFrom-Json
        Write-Info "Azure DevOps pull request created successfully!"
        Write-Output "Pull Request ID: $($result.pullRequestId)"
        Write-Output "URL: $($result.url)"
        return $true
    }
    catch {
        Write-Error "Failed to create Azure DevOps pull request: $_"
        return $false
    }
}

function New-InteractivePullRequest {
    Write-Header "Interactive Pull Request Creation"
    
    # Get current branch if not specified
    if (-not $SourceBranch) {
        $SourceBranch = Get-CurrentBranch
        Write-Info "Using current branch: $SourceBranch"
    }
    
    # Get repository information
    $repoInfo = Get-RepositoryInfo
    Write-Info "Detected platform: $($repoInfo.Platform)"
    
    # Get title if not specified
    if (-not $Title) {
        $Title = Read-Host "Enter pull request title"
    }
    
    # Get description if not specified
    if (-not $Description) {
        $template = Get-PullRequestTemplate $repoInfo.Platform
        if ($template) {
            Write-Info "Found pull request template. Using as base description."
            $Description = $template
        }
        
        Write-Info "Enter pull request description (press Enter twice to finish):"
        $descLines = @()
        do {
            $line = Read-Host
            if ($line -eq "" -and $descLines.Count -gt 0 -and $descLines[-1] -eq "") {
                break
            }
            $descLines += $line
        } while ($true)
        
        if ($descLines.Count -gt 0) {
            $Description = ($descLines[0..($descLines.Count-2)] -join "`n")
        }
    }
    
    # Show summary
    Write-Header "Pull Request Summary"
    Write-Output "Platform: $($repoInfo.Platform)"
    Write-Output "Title: $Title"
    Write-Output "Source Branch: $SourceBranch"
    Write-Output "Target Branch: $TargetBranch"
    Write-Output "Description: $($Description.Substring(0, [Math]::Min(100, $Description.Length)))..."
    
    $confirm = Read-Host "Create pull request? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Info "Pull request creation cancelled"
        return
    }
    
    # Create pull request based on platform
    $success = $false
    
    if ($repoInfo.Platform -eq "github") {
        $success = New-GitHubPullRequest -RepoInfo $repoInfo -Title $Title -Description $Description -SourceBranch $SourceBranch -TargetBranch $TargetBranch -Reviewers $Reviewers -Labels $Labels -Draft $Draft
    }
    elseif ($repoInfo.Platform -eq "azuredevops") {
        $success = New-AzureDevOpsPullRequest -RepoInfo $repoInfo -Title $Title -Description $Description -SourceBranch $SourceBranch -TargetBranch $TargetBranch -Reviewers $Reviewers -Draft $Draft -AutoComplete $AutoComplete
    }
    
    if ($success) {
        Write-Info "🎉 Pull request created successfully!"
    } else {
        Write-Error "❌ Failed to create pull request"
    }
}

# Main execution
if ($Help) {
    Show-Usage
    exit 0
}

# Validate git repository
if (-not (Test-GitRepository)) {
    Write-Error "Not in a git repository"
    exit 1
}

try {
    # Ensure we have the latest changes
    Write-Info "Fetching latest changes..."
    git fetch origin
    
    # Push current branch if it has commits
    if ($SourceBranch -or (Get-CurrentBranch) -ne $TargetBranch) {
        $currentBranch = if ($SourceBranch) { $SourceBranch } else { Get-CurrentBranch }
        
        Write-Info "Pushing branch '$currentBranch' to remote..."
        git push origin $currentBranch
    }
    
    # Create pull request
    New-InteractivePullRequest
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}