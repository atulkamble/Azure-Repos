# Troubleshooting Guide

This guide helps you resolve common issues when working with Git, GitHub, and Azure DevOps.

## 📋 Table of Contents

- [Git Issues](#git-issues)
- [GitHub Issues](#github-issues)
- [Azure DevOps Issues](#azure-devops-issues)
- [Visual Studio Issues](#visual-studio-issues)
- [Authentication Issues](#authentication-issues)
- [Performance Issues](#performance-issues)
- [General Solutions](#general-solutions)

---

## 🔧 Git Issues

### Issue: "fatal: not a git repository"
**Symptoms:** Git commands fail with this error
**Solutions:**
```bash
# Initialize a new repository
git init

# Or clone an existing repository
git clone <repository-url>

# Check if you're in the right directory
pwd
ls -la  # Look for .git folder
```

### Issue: Merge Conflicts
**Symptoms:** Git merge or pull fails with conflict messages
**Solutions:**
```bash
# View conflicted files
git status

# Edit conflicts manually, then:
git add <resolved-file>
git commit -m "Resolve merge conflict"

# Or use a merge tool
git mergetool
```

### Issue: "Your branch is ahead of origin/main by X commits"
**Symptoms:** Local branch has commits not pushed to remote
**Solutions:**
```bash
# Push your commits
git push origin main

# Or reset to remote (CAUTION: loses local commits)
git reset --hard origin/main
```

### Issue: Accidentally committed large files
**Symptoms:** Repository size is too large, push fails
**Solutions:**
```bash
# Remove from last commit
git reset HEAD~1
git rm --cached <large-file>
echo "<large-file>" >> .gitignore
git add .gitignore
git commit -m "Remove large file and update gitignore"

# For files in history, use BFG or git filter-branch
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch <large-file>' --prune-empty --tag-name-filter cat -- --all
```

### Issue: Wrong commit message
**Symptoms:** Need to change the last commit message
**Solutions:**
```bash
# Change last commit message (not pushed yet)
git commit --amend -m "Correct commit message"

# If already pushed (use with caution)
git commit --amend -m "Correct commit message"
git push --force-with-lease
```

---

## 🐙 GitHub Issues

### Issue: Permission denied (publickey)
**Symptoms:** Cannot push/pull with SSH
**Solutions:**
```bash
# Check SSH key
ssh -T git@github.com

# Generate new SSH key if needed
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub account
cat ~/.ssh/id_ed25519.pub
```

### Issue: Repository not found
**Symptoms:** "Repository not found" error when cloning
**Solutions:**
1. Check repository URL is correct
2. Verify you have access to the repository
3. Use HTTPS instead of SSH if having SSH issues
```bash
# Switch from SSH to HTTPS
git remote set-url origin https://github.com/username/repository.git
```

### Issue: Large file upload fails
**Symptoms:** "file exceeds GitHub's file size limit"
**Solutions:**
```bash
# Use Git LFS for large files
git lfs install
git lfs track "*.zip"
git lfs track "*.exe"
git add .gitattributes
git add <large-file>
git commit -m "Add large file with LFS"
```

---

## 🏢 Azure DevOps Issues

### Issue: "TF401019: The Git repository with name or identifier X does not exist"
**Symptoms:** Cannot access Azure DevOps repository
**Solutions:**
1. Verify repository name and organization
2. Check permissions in Azure DevOps
3. Ensure correct URL format:
```bash
# Correct Azure DevOps URL format
https://dev.azure.com/{organization}/{project}/_git/{repository}
```

### Issue: Authentication failures with Azure DevOps
**Symptoms:** Credentials rejected, 401 errors
**Solutions:**
```bash
# Use Personal Access Token
git config --global credential.helper store
# When prompted, use PAT as password

# Or use Azure CLI
az login
git config --global credential.helper manager-core
```

### Issue: Branch policies prevent push
**Symptoms:** "TF402455: Pushes to this branch are not permitted"
**Solutions:**
1. Create pull request instead of direct push
2. Check branch policies in Azure DevOps
3. Ensure you're not pushing to protected branch

### Issue: Work item linking not working
**Symptoms:** Commits not linking to work items
**Solutions:**
```bash
# Use correct format in commit message
git commit -m "Fix login issue AB#123"
# Where AB#123 is the work item ID

# Or use full URL
git commit -m "Fix login issue https://dev.azure.com/org/project/_workitems/edit/123"
```

---

## 🎨 Visual Studio Issues

### Issue: Git integration not working in Visual Studio
**Symptoms:** Git commands not available, no source control
**Solutions:**
1. Ensure Git for Windows is installed
2. Check Visual Studio Git settings:
   - Tools → Options → Source Control → Git Global Settings
3. Restart Visual Studio
4. Try opening folder instead of solution file

### Issue: Cannot see Azure DevOps repositories in Visual Studio
**Symptoms:** Connection to Azure DevOps fails
**Solutions:**
1. Install Azure DevOps extension for Visual Studio
2. Sign in with correct account:
   - File → Account Settings
3. Add Azure DevOps account in Team Explorer
4. Check network/firewall settings

### Issue: Merge conflicts not showing in Visual Studio
**Symptoms:** Cannot resolve conflicts in IDE
**Solutions:**
1. Use Visual Studio merge tool:
   - Team Explorer → Changes → Conflicts
2. Or resolve manually:
   - View → Other Windows → Git Repository
3. Alternative: use external merge tool

---

## 🔐 Authentication Issues

### Issue: Credential Manager issues on Windows
**Symptoms:** Wrong credentials cached, cannot authenticate
**Solutions:**
```cmd
# Clear Windows Credential Manager
cmdkey /list
cmdkey /delete:git:https://github.com
cmdkey /delete:git:https://dev.azure.com

# Or use Control Panel → Credential Manager
```

### Issue: Token expired
**Symptoms:** Authentication suddenly stops working
**Solutions:**
1. **GitHub:** Regenerate Personal Access Token
   - GitHub → Settings → Developer settings → Personal access tokens
2. **Azure DevOps:** Regenerate PAT
   - Azure DevOps → User Settings → Personal Access Tokens
3. Update stored credentials

### Issue: Two-factor authentication problems
**Symptoms:** Cannot authenticate with 2FA enabled
**Solutions:**
1. Use Personal Access Tokens instead of passwords
2. For GitHub: Generate app password
3. For Azure DevOps: Create PAT with appropriate scopes

---

## ⚡ Performance Issues

### Issue: Git operations are slow
**Symptoms:** Clone, fetch, push take very long
**Solutions:**
```bash
# Enable Git's parallel processing
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256

# Use shallow clone for large repositories
git clone --depth 1 <repository-url>

# Enable Git LFS if repository has large files
git lfs install
```

### Issue: Large repository size
**Symptoms:** Repository is several GB in size
**Solutions:**
```bash
# Clean up repository
git gc --prune=now --aggressive

# Check repository size
git count-objects -vH

# Find large files in history
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort --numeric-sort --key=2 | tail -10
```

---

## 🛠️ General Solutions

### Diagnostic Commands
```bash
# Check Git configuration
git config --list --show-origin

# Check repository status
git status
git log --oneline -10
git remote -v

# Check connectivity
ping github.com
ping dev.azure.com

# Verify Git installation
git --version
which git
```

### Reset Strategies
```bash
# Soft reset (keep changes in working directory)
git reset --soft HEAD~1

# Mixed reset (keep changes in working directory, unstage them)
git reset HEAD~1

# Hard reset (discard all changes - DANGEROUS)
git reset --hard HEAD~1

# Reset to remote state
git fetch origin
git reset --hard origin/main
```

### Backup Before Major Changes
```bash
# Create backup branch
git checkout -b backup-$(date +%Y%m%d)
git checkout main

# Stash changes
git stash push -m "Backup before troubleshooting"

# Export patches
git format-patch -1 HEAD
```

### Emergency Recovery
```bash
# Recover deleted branch
git reflog
git checkout -b recovered-branch <commit-hash>

# Recover deleted commits
git fsck --lost-found
git show <commit-hash>

# Undo last push (DANGEROUS)
git push --force-with-lease origin main
```

---

## 🆘 When All Else Fails

1. **Create a backup** of your work
2. **Document the exact error** message and steps to reproduce
3. **Check official documentation:**
   - [Git Documentation](https://git-scm.com/doc)
   - [GitHub Documentation](https://docs.github.com/)
   - [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)
4. **Search for the specific error** on Stack Overflow
5. **Contact support:**
   - GitHub Support: https://support.github.com/
   - Azure DevOps Support: https://azure.microsoft.com/support/devops/
6. **Ask the community:**
   - Stack Overflow with appropriate tags
   - GitHub Community Forum
   - Azure DevOps Developer Community

---

## 🚀 Prevention Tips

1. **Regular commits** with descriptive messages
2. **Frequent pulls** from remote repository
3. **Use .gitignore** properly from the start
4. **Test changes** in feature branches
5. **Keep repositories clean** and organized
6. **Use proper branch naming** conventions
7. **Regular backups** of important work
8. **Stay updated** with Git and tool versions
9. **Document your workflow** and share with team
10. **Practice Git commands** in test repositories

Remember: When in doubt, **create a backup** before trying any solution!