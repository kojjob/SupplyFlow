# SupplyFlow Git Workflow and Strategy

This document outlines the Git workflow and branching strategy for the SupplyFlow project. Following these guidelines ensures consistent, reliable, and efficient collaboration among team members.

## Table of Contents

1. [Branch Structure](#branch-structure)
2. [Naming Conventions](#naming-conventions)
3. [Workflow Process](#workflow-process)
4. [Commit Guidelines](#commit-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Code Review Standards](#code-review-standards)
7. [Deployment Process](#deployment-process)
8. [Handling Hotfixes](#handling-hotfixes)
9. [Git Best Practices](#git-best-practices)

## Branch Structure

We follow a modified GitFlow workflow with the following branch structure:

### Core Branches

- **`main`**: Production-ready code. This branch is deployed to the production environment.
- **`staging`**: Pre-production testing branch. This branch is deployed to the staging environment.
- **`develop`**: Integration branch for ongoing development. This branch is deployed to the development environment.

### Supporting Branches

- **Feature branches**: For new features and non-emergency bug fixes
- **Release branches**: For preparing releases
- **Hotfix branches**: For emergency production fixes

## Naming Conventions

### Branch Naming

- **Feature branches**: `feature/[issue-number]-[short-description]`
  - Example: `feature/123-add-mobile-money-integration`

- **Bug fix branches**: `bugfix/[issue-number]-[short-description]`
  - Example: `bugfix/456-fix-stock-calculation`

- **Release branches**: `release/[version-number]`
  - Example: `release/1.2.0`

- **Hotfix branches**: `hotfix/[issue-number]-[short-description]`
  - Example: `hotfix/789-fix-critical-payment-issue`

### Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- **Scope**: Optional component/module name
- **Subject**: Short description in present tense, not capitalized, no period at end
- **Body**: Optional detailed description
- **Footer**: Optional, for referencing issues

Examples:
- `feat(payment): add MTN Mobile Money integration`
- `fix(inventory): correct stock calculation formula`
- `docs(readme): update installation instructions`

## Workflow Process

### Feature Development

1. **Create a feature branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/123-add-mobile-money-integration
   ```

2. **Develop and commit changes**
   ```bash
   git add .
   git commit -m "feat(payment): implement MTN Mobile Money API client"
   ```

3. **Push branch to remote**
   ```bash
   git push -u origin feature/123-add-mobile-money-integration
   ```

4. **Create a Pull Request to `develop`**

5. **Address review feedback**

6. **Merge to `develop` after approval**

### Release Process

1. **Create a release branch from `develop`**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/1.2.0
   ```

2. **Make release-specific adjustments**
   - Version bumps
   - Last-minute fixes
   - Documentation updates

3. **Create a Pull Request to `staging`**

4. **Test thoroughly in staging environment**

5. **Create a Pull Request from `staging` to `main`**

6. **Deploy to production after approval**

7. **Tag the release**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.0 -m "Version 1.2.0"
   git push origin v1.2.0
   ```

8. **Merge changes back to `develop`**
   ```bash
   git checkout develop
   git merge --no-ff main
   git push origin develop
   ```

## Commit Guidelines

1. **Make atomic commits**
   - Each commit should represent a single logical change
   - This makes it easier to review, revert, and understand changes

2. **Write meaningful commit messages**
   - Follow the Conventional Commits format
   - Explain *what* and *why*, not *how*

3. **Commit early and often**
   - Don't wait until you have a large amount of changes
   - Regular commits create natural save points

4. **Verify your changes before committing**
   - Run tests
   - Check linting
   - Review your changes with `git diff`

## Pull Request Process

1. **Create a descriptive Pull Request**
   - Use the PR template
   - Reference related issues
   - Describe the changes and their purpose

2. **Assign reviewers**
   - At least one reviewer is required
   - Assign domain experts when appropriate

3. **Pass CI checks**
   - All automated tests must pass
   - Code quality checks must pass
   - No merge conflicts

4. **Address review feedback**
   - Respond to all comments
   - Make requested changes or explain why they shouldn't be made

5. **Get approval**
   - At least one approval is required
   - Some critical areas may require specific approvers

6. **Merge the Pull Request**
   - Use "Squash and merge" for feature branches
   - Use "Merge commit" for release and hotfix branches

## Code Review Standards

1. **What to look for**
   - Correctness: Does the code work as intended?
   - Security: Are there any security vulnerabilities?
   - Performance: Are there any performance issues?
   - Maintainability: Is the code easy to understand and modify?
   - Test coverage: Are there sufficient tests?

2. **Review etiquette**
   - Be respectful and constructive
   - Focus on the code, not the person
   - Explain your reasoning
   - Suggest alternatives when pointing out issues

3. **Response expectations**
   - Reviews should be completed within 24 business hours
   - Authors should respond to feedback within 24 business hours

## Deployment Process

### Development Environment

- Automatically deployed from the `develop` branch
- Deploys on every merge to `develop`

### Staging Environment

- Deployed from the `staging` branch
- Requires manual approval
- Used for QA and UAT

### Production Environment

- Deployed from the `main` branch
- Requires manual approval from a project lead
- Deployed during designated deployment windows

## Handling Hotfixes

1. **Create a hotfix branch from `main`**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b hotfix/789-fix-critical-payment-issue
   ```

2. **Implement and test the fix**

3. **Create a Pull Request to `main`**

4. **After approval, merge to `main`**

5. **Deploy to production**

6. **Tag the hotfix**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.1 -m "Hotfix: Fix critical payment issue"
   git push origin v1.2.1
   ```

7. **Merge changes to `develop` and `staging`**
   ```bash
   git checkout develop
   git merge --no-ff main
   git push origin develop
   
   git checkout staging
   git merge --no-ff main
   git push origin staging
   ```

## Git Best Practices

1. **Keep branches up to date**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/my-feature
   git rebase develop
   ```

2. **Use rebase to maintain a clean history**
   - Rebase your feature branch on develop before creating a PR
   - Use interactive rebase to clean up your commits before pushing

3. **Don't commit sensitive information**
   - No API keys, passwords, or tokens
   - Use environment variables and secrets management

4. **Use .gitignore properly**
   - Exclude build artifacts, dependencies, and local configuration
   - Include templates for configuration files with `.example` suffix

5. **Regularly clean up old branches**
   - Delete merged branches
   - Archive or delete stale branches

---

This Git workflow is designed to support the SupplyFlow development process. It may be adjusted as the project evolves and the team identifies improvements.

For questions or suggestions regarding this workflow, please contact the project lead or create an issue in the repository.
