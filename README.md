# Session 5 – Git Strategy & Git Internals

## 1. Git Internals

**Points:**
1. Working Directory → current files.
2. Staging Area → files selected for commit.
3. Local Repository → local commit history.
4. Remote Repository → GitHub/Azure Repos.
5. Git stores Blob, Tree, Commit and Tag objects.

**Flow:**

```text
Working Directory
      ↓ git add
Staging Area
      ↓ git commit
Local Repository
      ↓ git push
Remote Repository
```

**Commands:**

```bash
git init
git status
git add .
git commit -m "Initial commit"
git log --oneline
git push
```

Inspect internals:

```bash
ls -la .git
cat .git/HEAD

git cat-file -t HEAD
git cat-file -p HEAD
```

---

## 2. Trunk-Based Development

**Steps:**
1. Keep `main` as the trunk.
2. Create a short-lived feature branch.
3. Develop feature.
4. Commit changes.
5. Push branch.
6. Create Pull Request.
7. Review and test.
8. Merge into `main`.
9. Delete feature branch.

```bash
git switch main
git pull

git switch -c feature/login

echo "Login Feature" > login.txt

git add .
git commit -m "Add login feature"

git push -u origin feature/login
```

**Flow:**

```text
main
 ↓
feature/login
 ↓
Code
 ↓
Commit
 ↓
Push
 ↓
PR
 ↓
Review
 ↓
main
```

---

## 3. GitFlow

**Branches:**

```text
main        → Production
develop     → Development
feature/*   → New features
release/*   → Release preparation
hotfix/*    → Production fixes
```

**Practice:**

```bash
git switch main

git switch -c develop
git push -u origin develop

git switch -c feature/payment
```

After development:

```bash
git add .
git commit -m "Add payment feature"

git switch develop
git merge feature/payment
```

**Flow:**

```text
feature/*
    ↓
develop
    ↓
release/*
    ↓
main
    ↓
Production
```

---

## 4. GitFlow vs Trunk

| GitFlow | Trunk-Based |
|---|---|
| main + develop | mainly main |
| Longer branches | Short-lived branches |
| Release branches | Frequent releases |
| More complex | Simpler |
| Controlled releases | Continuous delivery |

---

## 5. Pull Requests & Reviews

**Steps:**
1. Create feature branch.
2. Make changes.
3. Commit.
4. Push.
5. Create PR.
6. Add reviewer.
7. Run CI checks.
8. Fix comments.
9. Approve.
10. Merge.

```bash
git switch -c feature/cart

echo "Shopping Cart" > cart.txt

git add .
git commit -m "Add shopping cart"

git push -u origin feature/cart
```

**Flow:**

```text
Developer
   ↓
Feature Branch
   ↓
Push
   ↓
Pull Request
   ↓
Review
   ↓
CI Checks
   ↓
Approval
   ↓
Merge
```

---

## 6. Branch Protection

**Recommended rules:**
1. Protect `main`.
2. Require Pull Request.
3. Require reviewer approval.
4. Require CI checks.
5. Require resolved comments.
6. Block force push.
7. Restrict deletion.

**Flow:**

```text
Developer
   ↓
feature/*
   ↓
PR
   ↓
Reviewer + CI
   ↓
Branch Protection
   ↓
main
```

---

## 7. Merge

```bash
git switch main
git pull

git merge feature/login

git push origin main
```

Merge keeps branch history.

```text
A---B---C-------M
     \         /
      D---E---
```

Abort merge:

```bash
git merge --abort
```

---

## 8. Rebase

```bash
git switch feature/login

git fetch origin

git rebase origin/main
```

**Flow:**

```text
Before:

A---B---C main
     \
      D---E feature


After:

A---B---C---D'---E'
```

Conflict resolution:

```bash
git status

# Fix conflicting files

git add .

git rebase --continue
```

Cancel:

```bash
git rebase --abort
```

---

## 9. Merge vs Rebase

| Merge | Rebase |
|---|---|
| Preserves history | Rewrites commits |
| Can create merge commit | Linear history |
| Safe for shared branches | Better for local branches |
| `git merge` | `git rebase` |

---

## 10. Tagging & Releases

Create tag:

```bash
git tag v1.0.0
```

Recommended annotated tag:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
```

List:

```bash
git tag
```

Push:

```bash
git push origin v1.0.0
```

Push all:

```bash
git push origin --tags
```

**Versioning:**

```text
v2.4.1

2 → Major
4 → Minor
1 → Patch
```

**Flow:**

```text
main
 ↓
Stable Commit
 ↓
Tag
 ↓
v1.0.0
 ↓
Release
```

---

## 11. Git Security

Never commit:

```text
Passwords
API Keys
PAT Tokens
AWS Keys
Azure Secrets
Private SSH Keys
.env
Terraform State
```

Create `.gitignore`:

```gitignore
.env
*.pem
*.key
*.tfstate
*.tfstate.*
credentials.json
secrets/
node_modules/
```

Check tracked files:

```bash
git ls-files
```

---

# Session 6 – GitHub

## 1. GitHub Overview

[GitHub](https://github.com/?utm_source=chatgpt.com) provides:

1. Git repository hosting.
2. Branch management.
3. Pull Requests.
4. Issues.
5. GitHub Actions.
6. Security.
7. Projects.
8. Codespaces.
9. Webhooks.
10. Releases.

**Flow:**

```text
Repository
   ↓
Branch
   ↓
Commit
   ↓
PR
   ↓
Actions
   ↓
Review
   ↓
Merge
   ↓
Release
```

---

## 2. Create GitHub Repository

**Steps:**
1. GitHub → New Repository.
2. Enter repository name.
3. Select Public/Private.
4. Create repository.

Local commands:

```bash
mkdir git-practice
cd git-practice

git init

echo "# Git Practice" > README.md

git add .
git commit -m "Initial commit"

git branch -M main

git remote add origin <github-repository-url>

git push -u origin main
```

Check remote:

```bash
git remote -v
```

---

## 3. GitHub Actions – Introduction

Create:

```text
.github/workflows/ci.yml
```

```yaml
name: CI Pipeline

on:
  push:
    branches:
      - main

  pull_request:
    branches:
      - main

jobs:

  build:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: Build
        run: |
          echo "Building application"

      - name: Test
        run: |
          echo "Testing application"
```

**Flow:**

```text
Push / PR
    ↓
Trigger
    ↓
Workflow
    ↓
Job
    ↓
Runner
    ↓
Steps
    ↓
Build + Test
```

---

## 4. GitHub Branch Protection

**Steps:**

```text
Repository
   ↓
Settings
   ↓
Rules
   ↓
Rulesets
   ↓
New Ruleset
   ↓
Target main
```

Enable appropriate rules:

1. Require Pull Request.
2. Require approvals.
3. Require status checks.
4. Block force push.
5. Restrict branch deletion.

---

## 5. GitHub Security

Important features:

1. Dependabot.
2. Secret scanning.
3. Push protection.
4. CodeQL.
5. Dependency review.

### Dependabot

Create:

```text
.github/dependabot.yml
```

Example:

```yaml
version: 2

updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## 6. GitHub Secrets

Go to:

```text
Repository
 ↓
Settings
 ↓
Secrets and variables
 ↓
Actions
 ↓
New repository secret
```

Examples:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Use in Actions:

```yaml
env:
  DOCKER_USER: ${{ secrets.DOCKERHUB_USERNAME }}
```

---

## 7. GitHub Codespaces

**Steps:**

```text
Repository
 ↓
Code
 ↓
Codespaces
 ↓
Create Codespace
```

Practice inside Codespace:

```bash
git status

git switch -c feature/codespace

echo "Codespace Test" > codespace.txt

git add .
git commit -m "Codespace test"

git push -u origin feature/codespace
```

---

## 8. GitHub Webhooks

**Steps:**

```text
Repository
 ↓
Settings
 ↓
Webhooks
 ↓
Add Webhook
 ↓
Payload URL
 ↓
Select Events
 ↓
Save
```

Common events:

```text
push
pull_request
issues
release
```

**Flow:**

```text
Developer Push
      ↓
GitHub
      ↓
Webhook
      ↓
HTTP POST
      ↓
Jenkins / Application
      ↓
Pipeline
```

---

## 9. GitHub Projects

**Steps:**
1. Create Project.
2. Create issues/tasks.
3. Add tasks to board.
4. Assign developers.
5. Track status.

```text
Backlog
   ↓
Todo
   ↓
In Progress
   ↓
Review
   ↓
Done
```

---

## 10. GitHub ↔ Azure DevOps

Example architecture:

```text
GitHub
   ↓
Azure Pipelines
   ↓
Build
   ↓
Test
   ↓
Docker Build
   ↓
Container Registry
   ↓
AKS
```

Basic Azure Pipeline:

```yaml
trigger:
  - main

pool:
  vmImage: ubuntu-latest

steps:

  - checkout: self

  - script: |
      echo "GitHub → Azure Pipeline"
      ls
    displayName: Build
```

**Steps:**

```text
Azure DevOps
 ↓
Pipelines
 ↓
New Pipeline
 ↓
GitHub
 ↓
Authorize
 ↓
Select Repository
 ↓
Select/Create YAML
 ↓
Run
```

---

# Session 7 – Azure Repos

## 1. Azure Repos Overview

[Azure DevOps](https://dev.azure.com/?utm_source=chatgpt.com)

```text
Azure DevOps
    ↓
Project
    ↓
Repos
    ↓
Repository
    ↓
Branches
    ↓
Pull Requests
```

---

## 2. Clone Azure Repository

Copy clone URL from:

```text
Repos
 ↓
Files
 ↓
Clone
```

Run:

```bash
git clone <azure-repos-url>

cd <repository>

git status
```

---

## 3. Create Feature Branch

```bash
git switch main
git pull

git switch -c feature/login
```

Create change:

```bash
echo "Login Feature" > login.txt

git add .
git commit -m "Add login feature"

git push -u origin feature/login
```

---

## 4. Azure Repos Pull Request

**Steps:**

```text
Repos
 ↓
Pull Requests
 ↓
New Pull Request
```

Configure:

```text
Source → feature/login

Target → main
```

Then:

```text
Add Reviewer
     ↓
Review
     ↓
Build Validation
     ↓
Approve
     ↓
Complete PR
```

---

## 5. Repo / Branch Policies

Go to:

```text
Repos
 ↓
Branches
 ↓
main
 ↓
Branch Policies
```

Configure:

1. Minimum reviewers → `2`
2. Check linked work items.
3. Check comment resolution.
4. Build validation.
5. Automatic reviewers where needed.
6. Control merge types.

**Flow:**

```text
feature/*
   ↓
PR
   ↓
Branch Policy
   ├── Reviewers
   ├── Build
   ├── Tests
   └── Comments
         ↓
       Approval
         ↓
        main
```

---

## 6. Branch Permissions

Important permissions:

```text
Read
Contribute
Create Branch
Create Tag
Force Push
Manage Permissions
Bypass Policies
```

For `main`, restrict unnecessary:

```text
Force Push
Bypass Policies
Direct Changes
```

Use:

```text
Developer
   ↓
Feature Branch
   ↓
PR
   ↓
Policy
   ↓
Reviewer
   ↓
main
```

---

## 7. Monorepo vs Polyrepo

### Monorepo

```text
ecommerce/
├── frontend/
├── backend/
├── payment/
├── terraform/
└── kubernetes/
```

### Polyrepo

```text
frontend-repo
backend-repo
payment-repo
terraform-repo
kubernetes-repo
```

| Monorepo | Polyrepo |
|---|---|
| One repository | Multiple repositories |
| Multiple components | Separate component repos |
| Easier shared changes | Better isolation |
| Central CI can be complex | Independent CI/CD |
| Central permissions | Granular permissions |

---

## 8. Repository Migration

**Flow:**

```text
GitHub / Old Repo
       ↓
Mirror Clone
       ↓
Azure Repos
       ↓
Mirror Push
       ↓
Verify
```

Commands:

```bash
git clone --mirror <old-repository-url>

cd project.git

git push --mirror <azure-repository-url>
```

Verify:

```bash
git branch -a
git tag
git log --all --oneline
```

Remember that PRs, issues, permissions, secrets and pipelines may require separate migration.

---

## 9. Code Ownership

Purpose:

```text
Code Change
    ↓
Responsible Team
    ↓
Automatic Reviewer
    ↓
Review
    ↓
Approval
```

Example ownership model:

```text
/frontend/    → Frontend Team
/backend/     → Backend Team
/terraform/   → Cloud Team
/k8s/         → Platform Team
```

In Azure Repos, branch policies and automatically included reviewers can enforce ownership-style reviews.

---

## 10. Audit Logs

Track:

1. User activity.
2. Repository changes.
3. Permission changes.
4. Policy changes.
5. Administrative changes.
6. Security-related activity.

```text
WHO
 ↓
WHAT
 ↓
WHEN
 ↓
ACTION
```

---

## 11. Governance

Recommended enterprise controls:

1. Protect `main`.
2. No direct production pushes.
3. Require PR.
4. Require 1–2 reviewers.
5. Configure code owners/automatic reviewers.
6. Require CI.
7. Require tests.
8. Add security scanning.
9. Protect secrets.
10. Restrict force push.
11. Use semantic tags.
12. Maintain audit logs.
13. Apply least privilege.
14. Periodically review repository access.

---

# Complete Practical Flow

```text
Developer
    ↓
git clone
    ↓
git switch -c feature/login
    ↓
Code Changes
    ↓
git add .
    ↓
git commit
    ↓
git push
    ↓
Pull Request
    ↓
Branch Protection / Policies
    ↓
Code Owner / Reviewer
    ↓
CI Build
    ↓
Unit Tests
    ↓
Security Scan
    ↓
Approval
    ↓
Merge
    ↓
main
    ↓
Tag v1.0.0
    ↓
Release
    ↓
Deployment
    ↓
Audit + Governance
```

### Essential commands to remember

```bash
# Repository
git init
git clone <url>

# Status
git status

# Branch
git branch
git switch -c feature/login
git switch main

# Changes
git add .
git commit -m "message"

# Remote
git remote -v
git pull
git push
git push -u origin feature/login

# History
git log --oneline
git log --oneline --graph --all

# Merge
git merge feature/login

# Rebase
git rebase main

# Tags
git tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```
