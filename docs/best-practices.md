# Best Practices for Git and Azure DevOps

This guide outlines best practices for effective version control, collaboration, and DevOps workflows.

## 📋 Table of Contents

- [Git Best Practices](#git-best-practices)
- [Branching Strategy](#branching-strategy)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Best Practices](#pull-request-best-practices)
- [Azure DevOps Best Practices](#azure-devops-best-practices)
- [Security Best Practices](#security-best-practices)
- [Performance Optimization](#performance-optimization)
- [Team Collaboration](#team-collaboration)

---

## 🔧 Git Best Practices

### Repository Structure
```
project-root/
├── .gitignore              # Comprehensive ignore rules
├── .gitattributes          # Git attributes for file handling
├── README.md               # Project documentation
├── LICENSE                 # License information
├── CONTRIBUTING.md         # Contribution guidelines
├── CHANGELOG.md            # Version history
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
├── scripts/                # Build and deployment scripts
└── .github/ or .azuredevops/  # Platform-specific configurations
```

### Configuration
```bash
# Set up identity
git config --global user.name "Your Full Name"
git config --global user.email "your.work.email@company.com"

# Enable helpful settings
git config --global core.autocrlf input    # Mac/Linux
git config --global core.autocrlf true     # Windows
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.default simple

# Enable rerere (reuse recorded resolution)
git config --global rerere.enabled true

# Set up aliases for efficiency
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### File Management
```bash
# Use .gitignore effectively
echo "node_modules/" >> .gitignore
echo "*.log" >> .gitignore
echo ".env" >> .gitignore
echo "build/" >> .gitignore

# Use .gitattributes for consistent line endings
echo "* text=auto" > .gitattributes
echo "*.sh text eol=lf" >> .gitattributes
echo "*.bat text eol=crlf" >> .gitattributes
```

---

## 🌿 Branching Strategy

### Git Flow Model
```
main/master     ←── Production-ready code
├── develop     ←── Integration branch
│   ├── feature/user-auth
│   ├── feature/payment-system
│   └── feature/dashboard
├── release/1.2.0  ←── Preparing release
└── hotfix/critical-bug  ←── Emergency fixes
```

### Branch Naming Conventions
```bash
# Feature branches
feature/ticket-123-user-authentication
feature/add-payment-gateway
feature/improve-dashboard-ui

# Bug fix branches
bugfix/fix-login-validation
bugfix/resolve-memory-leak
fix/issue-456-csrf-vulnerability

# Hotfix branches
hotfix/security-patch-v1.2.1
hotfix/critical-performance-fix

# Release branches
release/v1.2.0
release/2023-spring-release

# Experimental branches
experiment/new-ui-framework
poc/microservices-architecture
```

### Branch Management
```bash
# Create and switch to feature branch
git checkout -b feature/user-auth develop

# Keep feature branch updated
git checkout develop
git pull origin develop
git checkout feature/user-auth
git merge develop

# Or use rebase for cleaner history
git rebase develop

# Clean up merged branches
git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d
```

---

## 📝 Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code formatting, no logic changes
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, build changes

### Examples
```bash
# Good commit messages
git commit -m "feat(auth): add OAuth2 integration with Google"
git commit -m "fix(api): resolve null pointer exception in user service"
git commit -m "docs: update API documentation with new endpoints"
git commit -m "refactor(database): optimize query performance for user lookup"

# Include breaking changes
git commit -m "feat(api): change authentication method

BREAKING CHANGE: API now requires JWT tokens instead of session cookies.
Update client applications to use Authorization header."
```

### Commit Best Practices
```bash
# Atomic commits - one logical change per commit
git add src/auth/oauth.js
git commit -m "feat(auth): add OAuth2 service class"

git add tests/auth/oauth.test.js
git commit -m "test(auth): add unit tests for OAuth2 service"

# Use interactive staging for precise commits
git add -p

# Amend last commit if not pushed yet
git commit --amend -m "Updated commit message"

# Split large commits
git reset HEAD~1
git add -p
git commit -m "First part of the change"
git add -p
git commit -m "Second part of the change"
```

---

## 🔄 Pull Request Best Practices

### PR Structure
```markdown
## Summary
Brief description of changes made

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
```

### PR Workflow
```bash
# Before creating PR
git checkout feature/user-auth
git rebase develop                    # Clean up history
git push -u origin feature/user-auth

# Create PR through web interface or CLI
gh pr create --title "Add user authentication" --body-file pr-template.md

# Address review feedback
git add .
git commit -m "address: update validation logic per review"
git push origin feature/user-auth

# Merge PR (use appropriate merge strategy)
# - Merge commit: preserves branch history
# - Squash merge: clean linear history
# - Rebase merge: linear history without merge commit
```

### Code Review Guidelines

**For Authors:**
- Keep PRs small and focused (< 400 lines)
- Provide clear description and context
- Add tests for new functionality
- Update documentation
- Self-review before requesting review
- Be responsive to feedback

**For Reviewers:**
- Review promptly (within 24 hours)
- Be constructive and specific
- Focus on logic, maintainability, and standards
- Ask questions for clarity
- Approve when confident in changes
- Test locally for complex changes

---

## 🏢 Azure DevOps Best Practices

### Repository Settings
```yaml
# Branch Policies for main branch
policies:
  - require_pull_request: true
  - minimum_reviewers: 2
  - dismiss_stale_reviews: true
  - require_code_owner_review: true
  - require_status_checks: true
  - require_up_to_date_branches: true
  - allow_force_pushes: false
  - allow_deletions: false
```

### Work Item Integration
```bash
# Link commits to work items
git commit -m "Fix authentication bug AB#123"
git commit -m "Implement user profile feature AB#456, AB#789"

# Auto-complete work items
git commit -m "Complete user story AB#123 #resolve"
```

### Pipeline Configuration
```yaml
# azure-pipelines.yml best practices
trigger:
  branches:
    include: [main, develop]
  paths:
    exclude: [docs/*, '**/*.md']

pr:
  branches:
    include: [main, develop]

variables:
  - group: 'Build Variables'
  - name: 'buildConfiguration'
    value: 'Release'

stages:
  - stage: Build
    jobs:
      - job: BuildAndTest
        steps:
          - task: UseDotNet@2
          - task: DotNetCoreCLI@2
          - task: PublishTestResults@2
          - task: PublishCodeCoverageResults@1
```

---

## 🔒 Security Best Practices

### Credential Management
```bash
# Never commit credentials
echo ".env" >> .gitignore
echo "secrets.json" >> .gitignore
echo "*.key" >> .gitignore
echo "*.pem" >> .gitignore

# Use environment variables
export DATABASE_URL="postgres://user:pass@localhost/db"
export API_KEY="your-secret-key"

# Use Azure Key Vault or similar services
az keyvault secret set --vault-name "MyKeyVault" --name "DatabasePassword" --value "SecretValue"
```

### Repository Security
```bash
# Enable branch protection
# - Require status checks
# - Require branches to be up to date
# - Require review from code owners
# - Restrict pushes to main branch

# Use signed commits
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgSign true
```

### Secrets Scanning
```yaml
# GitHub Actions security scanning
- name: Run security scan
  uses: github/super-linter@v4
  env:
    DEFAULT_BRANCH: main
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# Azure DevOps security scan
- task: WhiteSource Bolt@20
- task: CredScan@2
```

---

## ⚡ Performance Optimization

### Repository Size Management
```bash
# Check repository size
git count-objects -vH

# Clean up repository
git gc --prune=now --aggressive

# Use Git LFS for large files
git lfs install
git lfs track "*.zip"
git lfs track "*.exe"
git lfs track "*.dmg"

# Shallow clone for CI/CD
git clone --depth 1 <repository-url>
```

### Build Optimization
```yaml
# Cache dependencies in Azure Pipelines
- task: Cache@2
  inputs:
    key: 'npm | "$(Agent.OS)" | package-lock.json'
    restoreKeys: |
      npm | "$(Agent.OS)"
    path: $(npm_config_cache)

# Parallel job execution
strategy:
  matrix:
    linux:
      imageName: 'ubuntu-latest'
    mac:
      imageName: 'macOS-latest'
    windows:
      imageName: 'windows-latest'
```

---

## 👥 Team Collaboration

### Team Setup
```bash
# Consistent environment setup
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase false

# Shared Git hooks
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Communication
- Use descriptive commit messages
- Reference issues/work items in commits
- Update project documentation regularly
- Conduct regular code reviews
- Share knowledge through documentation

### Onboarding Checklist
- [ ] Git installed and configured
- [ ] SSH keys or credentials set up
- [ ] Repository access granted
- [ ] Development environment configured
- [ ] Branch naming conventions understood
- [ ] Code review process explained
- [ ] CI/CD pipeline access granted

---

## 📊 Monitoring and Metrics

### Repository Health
```bash
# Monitor repository statistics
git shortlog -sn --all          # Contributor statistics
git log --since="1 month ago" --oneline | wc -l  # Commits this month
git ls-files | wc -l            # Total files tracked
```

### Code Quality Metrics
- Code coverage percentage
- Technical debt ratio
- Code complexity metrics
- Security vulnerability count
- Build success rate
- Deployment frequency

### Team Metrics
- Pull request merge time
- Code review participation
- Bug detection in review vs. production
- Feature delivery velocity
- Hotfix frequency

---

## 🚀 Advanced Tips

### Git Hooks
```bash
# Pre-commit hook for code quality
#!/bin/sh
npm run lint
npm run test
echo "Pre-commit checks passed"
```

### Custom Git Commands
```bash
# Add to ~/.gitconfig
[alias]
    publish = "!git push -u origin $(git branch --show-current)"
    unpublish = "!git push origin :$(git branch --show-current)"
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|develop' | xargs -n 1 git branch -d"
```

### Automation Scripts
```bash
#!/bin/bash
# Daily development routine
git checkout main
git pull origin main
git branch --merged | grep -v "main" | xargs git branch -d
git gc --prune=now
echo "Repository maintenance completed"
```

---

Remember: **Consistency is key**. Choose practices that work for your team and stick to them across all projects.