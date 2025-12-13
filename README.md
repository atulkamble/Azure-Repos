# 🚀 **Git, GitHub & Azure DevOps - Complete Guide**

A comprehensive guide covering Git version control, GitHub collaboration, and Azure DevOps workflows with practical examples, scripts, and best practices.

## 📋 **Table of Contents**

- [Overview](#overview)
- [Git Fundamentals](#git-fundamentals)
- [Azure DevOps Setup](#azure-devops-setup)
- [GitHub Integration](#github-integration)
- [Visual Studio Integration](#visual-studio-integration)
- [Scripts and Automation](#scripts-and-automation)
- [Best Practices](#best-practices)

## 🎯 **Overview**

This repository provides comprehensive documentation and practical examples for:
- Git version control basics and advanced workflows
- Azure DevOps repository management
- GitHub integration with Azure Boards
- Visual Studio integration for seamless development
- Automation scripts for common tasks

## 📚 **Topics Covered**

1. **Git Fundamentals**: `.gitignore`, credentials, branching
2. **Azure DevOps**: TFVC, Azure Repos, Pull Requests
3. **GitHub Integration**: Azure Boards integration, repository imports
4. **Visual Studio**: Repository management, branch creation, code pushing
5. **Automation**: Scripts for common Git and Azure DevOps operations

---

# ✅ **Git, GitHub & Azure DevOps – Complete Notes + Commands + Code**

---

## 🔹 **1. What is `.gitignore`?**

`.gitignore` tells Git which files/folders **NOT to track** (logs, temp files, credentials, binaries, build artifacts).

### ✔ Example `.gitignore`

```gitignore
# OS Files
.DS_Store
Thumbs.db

# Logs
*.log

# Node Modules
node_modules/

# Python venv
venv/

# Terraform
.terraform/
*.tfstate

# Azure DevOps Pipelines
*.publishsettings
```

---

## 🔹 **2. Team Foundation Version Control (TFVC)**

* Centralized version control (not distributed like Git).
* Every user checks in/out files.
* Replaced mostly by Git in Azure DevOps.

### ✔ Enable TFVC in Azure DevOps

Azure DevOps → **Repos → Files → Switch to TFVC**

---

## 🔹 **3. Integration of Azure Boards with GitHub**

Track GitHub commits/issues directly in Azure Boards.

### ✔ Steps

1. Azure Boards → *Project Settings*
2. GitHub Connections → *New Connection*
3. Authorize GitHub OAuth
4. Select GitHub repositories
5. Use commit messages with Work Item ID:

```text
Fix homepage issue AB#123
```

---

## 🔹 **4. Azure Repos Fork**

Fork = Create a copy of Azure Repo for experimentation.

### ✔ Steps

Azure DevOps → Repos → Select Repo → **Fork**
Choose:

* Project
* Repo Name
  Click **Create**

---

# 🧩 **5. Git Credential Setup**

Store credentials securely.

### ✔ Windows

```bash
git config --global credential.helper manager-core
```

### ✔ Mac / Linux

```bash
git config --global credential.helper store
```

---

# 🧩 **6. Clone Azure DevOps Repository**

### ✔ HTTPS

```bash
git clone https://dev.azure.com/<org>/<project>/_git/<repo>
```

### ✔ SSH

```bash
git clone git@ssh.dev.azure.com:v3/<org>/<project>/<repo>
```

---

# 🧩 **7. Import GitHub Repo into Azure Repos**

Azure DevOps → Repos → Import Repository

Enter:

```
https://github.com/<username>/<repo>.git
```

Or CLI:

```bash
git clone https://github.com/user/repo.git
cd repo
git remote add azure https://dev.azure.com/org/proj/_git/repo
git push azure --all
```

---

# 🔹 **8. Azure Repos Overview**

Azure Repos provides:
✔ Unlimited cloud-hosted git repos
✔ Pull requests
✔ Policies
✔ Branch protection
✔ TFVC support

---

# 🔹 **9. Push Branches to Remote Repo**

### ✔ Push new branch

```bash
git checkout -b feature1
git add .
git commit -m "feature1 work done"
git push -u origin feature1
```

---

# 🔹 **10. Pull From Remote Repo**

### ✔ Pull latest changes

```bash
git pull origin main
```

### ✔ Fetch all branches

```bash
git fetch --all
```

---

# 🔹 **11. Create Pull Request**

### ✔ Using Azure DevOps UI

Repos → Pull Requests → *New Pull Request*

### ✔ Using GitHub UI

Compare & Pull Request → Create PR

### ✔ CLI

```bash
gh pr create --title "Fix Bug" --body "Resolved issue"
```

---

# 🧩 **12. Work on Git Repository in Visual Studio**

1. Open Visual Studio
2. File → Clone a Repository
3. Paste Azure Repo URL
4. Work on solution
5. Add/Commit/Push from **Git Changes** window

---

# 🧩 **13. Create GitHub Branches using Visual Studio**

Steps:

1. VS → Git → Manage Branches
2. Create New Branch → Provide Name
3. Push branch
4. Publish Branch

---

# 🧩 **14. Push Code to Azure Repos via Visual Studio**

Steps:

1. Open Solution
2. Go to: **Git → Create Git Repository**
3. Add Azure Repo URL
4. Commit All
5. Push → Publish Branch

---

## 💠 **Project Structure**

```
Azure-Repos/
 ├── src/                           # Source code examples
 │   ├── app.py                     # Sample Python application
 │   ├── index.html                 # Sample web page
 │   └── config.json                # Configuration file
 ├── scripts/                       # Automation scripts
 │   ├── setup-git-credentials.sh   # Git credential setup
 │   ├── azure-repo-clone.sh        # Azure repo cloning script
 │   ├── branch-management.sh       # Branch management utilities
 │   └── pull-request-automation.ps1 # PowerShell PR automation
 ├── templates/                     # Template files
 │   ├── .gitignore.template        # Comprehensive gitignore
 │   ├── azure-pipelines.yml        # CI/CD pipeline template
 │   └── PR-template.md             # Pull request template
 ├── docs/                          # Additional documentation
 │   ├── troubleshooting.md         # Common issues and solutions
 │   ├── best-practices.md          # Git and Azure DevOps best practices
 │   └── advanced-workflows.md      # Advanced Git workflows
 ├── examples/                      # Working examples
 │   ├── simple-project/            # Basic project structure
 │   └── enterprise-project/        # Enterprise-level structure
 ├── README.md                      # This file
 └── .gitignore                     # Git ignore rules
```

---

## 🎯 **Quick Start Guide**

### 🔧 **Prerequisites**

- Git installed ([Download](https://git-scm.com/downloads))
- Azure DevOps account ([Sign up](https://dev.azure.com/))
- Visual Studio or VS Code ([Download](https://visualstudio.microsoft.com/))

### ⚡ **Getting Started**

1. **Clone this repository**:
   ```bash
   git clone https://github.com/atulkamble/Azure-Repos.git
   cd Azure-Repos
   ```

2. **Run setup script**:
   ```bash
   chmod +x scripts/setup-git-credentials.sh
   ./scripts/setup-git-credentials.sh
   ```

3. **Explore examples**:
   ```bash
   cd examples/simple-project
   ```

---

## 🔧 **Configuration**

### 🌍 **Global Git Configuration**

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@domain.com"

# Set default branch name
git config --global init.defaultBranch main

# Enable helpful colorization
git config --global color.ui auto

# Set up aliases for common commands
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.up 'pull --rebase'
```

### 🔐 **Azure DevOps Personal Access Token Setup**

1. Go to Azure DevOps → User Settings → Personal Access Tokens
2. Create new token with required permissions
3. Store securely using:
   ```bash
   git config --global credential.helper store
   echo "https://YOUR_USERNAME:YOUR_PAT@dev.azure.com" >> ~/.git-credentials
   ```

---

## 🚀 **Advanced Workflows**

### 🌿 **Git Flow Workflow**

```bash
# Initialize git flow
git flow init

# Start a new feature
git flow feature start feature-name

# Finish a feature
git flow feature finish feature-name

# Start a release
git flow release start 1.0.0

# Finish a release
git flow release finish 1.0.0
```

### 🔄 **Continuous Integration with Azure Pipelines**

See [templates/azure-pipelines.yml](templates/azure-pipelines.yml) for a complete CI/CD setup.

---

## 🛠️ **Available Scripts**

All scripts are located in the `scripts/` directory:

- **`setup-git-credentials.sh`**: Configure Git credentials across platforms
- **`azure-repo-clone.sh`**: Batch clone multiple Azure repositories
- **`branch-management.sh`**: Create, manage, and sync branches
- **`pull-request-automation.ps1`**: Automate PR creation and management

---

## 🧪 **Testing**

Run the test script to verify your Git and Azure DevOps setup:

```bash
./scripts/test-setup.sh
```

---

## 🤝 **Contributing**

1. Fork this repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature-name`
5. Create a Pull Request

---

## 📖 **Additional Resources**

- [Git Documentation](https://git-scm.com/doc)
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Visual Studio Git Features](https://docs.microsoft.com/en-us/visualstudio/version-control/)

---

## 📝 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙋‍♂️ **Support**

If you have questions or need help:
- Check the [troubleshooting guide](docs/troubleshooting.md)
- Open an [issue](../../issues)
- Contact: [your-email@domain.com](mailto:your-email@domain.com)

---

**Made with ❤️ by [Atul Kamble](https://github.com/atulkamble)**
