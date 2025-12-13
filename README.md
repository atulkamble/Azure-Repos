What is gitignore, Team Foundation Version Control (TFVC), Integration of Azure Boards & Git Hub, Azure Repos Fork, Git Credential, Clone of Azure DevOps Repos, Import Repository from Git Hub to Azure Repos, Azure Repos, How to push branches to Remote Repository, How to Pull from Remote Repository, Pull Request, How to work on Git Repository Using Visual Studio, How to Create Git Hub Branches Using Visual Studio, How to Push Code to Azure Repos Using Visual Studio


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

## 💠 Example folder structure for Azure Repos

```
myproject/
 ├── src/
 │   ├── app.py
 │   └── index.html
 ├── tests/
 ├── README.md
 ├── azure-pipelines.yml
 └── .gitignore
```

---
