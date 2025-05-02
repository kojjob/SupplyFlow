# SupplyFlow Git Branching Strategy

This document provides a visual representation of our Git branching strategy and explains how different types of branches interact.

## Branching Model Visualization

```
    Production
    Environment
        ▲
        │
        │                                     ┌─── Hotfix Branch
        │                                     │     hotfix/789-fix-payment
main ───┼───────────────●─────────────────●──┴─●────────────────────────────●───▶
        │               │                 │    │                              │
        │               │                 │    │                              │
        │               │                 │    │                              │
        │               │                 │    │                              │
        │               │                 │    │                              │
staging ┼───────────●───┴───●─────────●───┘    │                              │
        │           │       │         │         │                              │
        │           │       │         │         │                              │
        │           │       │         │         │                              │
        │           │       │         │         │                              │
develop ┼───●───●───┴───●───┴─────●───┴─────────┴──────────────────────●───●───┘
        │   │   │       │           │                                  │   │
        │   │   │       │           │                                  │   │
        │   │   │       │           │                                  │   │
        │   │   │       │           └─── Release Branch                │   │
        │   │   │       │                 release/1.2.0               │   │
        │   │   │       │                                              │   │
        │   │   │       └─── Feature Branch                           │   │
        │   │   │             feature/456-stock-alerts                │   │
        │   │   │                                                      │   │
        │   │   └─── Bugfix Branch                                    │   │
        │   │         bugfix/123-calculation-error                    │   │
        │   │                                                          │   │
        │   └─── Feature Branch                                       │   │
        │         feature/789-mobile-money                           │   │
        │                                                              │   │
        └─── Initial Development                                      └───┘
                                                                   Merge back
                                                                  to develop
    Development
    Environment
```

## Branch Types and Lifecycle

### Core Branches

#### `main` Branch
- **Purpose**: Production-ready code
- **Lifetime**: Permanent
- **Merges from**: `staging` (via PR), `hotfix/*` (via PR)
- **Deploys to**: Production environment
- **Protection**: Requires PR approval, passing CI, and lead sign-off

#### `staging` Branch
- **Purpose**: Pre-production testing
- **Lifetime**: Permanent
- **Merges from**: `release/*` (via PR)
- **Merges to**: `main` (via PR)
- **Deploys to**: Staging environment
- **Protection**: Requires PR approval and passing CI

#### `develop` Branch
- **Purpose**: Integration branch for development
- **Lifetime**: Permanent
- **Merges from**: Feature branches, bugfix branches
- **Merges to**: Release branches
- **Deploys to**: Development environment
- **Protection**: Requires PR approval and passing CI

### Supporting Branches

#### Feature Branches `feature/*`
- **Purpose**: Developing new features
- **Naming**: `feature/[issue-number]-[short-description]`
- **Branch from**: `develop`
- **Merge to**: `develop` (via PR)
- **Lifetime**: Temporary (deleted after merge)

#### Bugfix Branches `bugfix/*`
- **Purpose**: Fixing non-critical bugs
- **Naming**: `bugfix/[issue-number]-[short-description]`
- **Branch from**: `develop`
- **Merge to**: `develop` (via PR)
- **Lifetime**: Temporary (deleted after merge)

#### Release Branches `release/*`
- **Purpose**: Preparing for a release
- **Naming**: `release/[version-number]`
- **Branch from**: `develop`
- **Merge to**: `staging` (via PR), then `main` (via PR)
- **Lifetime**: Temporary (deleted after merge to main)

#### Hotfix Branches `hotfix/*`
- **Purpose**: Emergency fixes for production
- **Naming**: `hotfix/[issue-number]-[short-description]`
- **Branch from**: `main`
- **Merge to**: `main` (via PR), then `develop` and `staging`
- **Lifetime**: Temporary (deleted after merge)

## Branch Flow Examples

### Feature Development Flow

1. Create a feature branch from `develop`
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/123-add-mobile-money
   ```

2. Develop, commit, and push changes
   ```bash
   # Make changes...
   git add .
   git commit -m "feat(payment): implement mobile money integration"
   git push -u origin feature/123-add-mobile-money
   ```

3. Create PR to `develop`

4. After approval and CI passes, merge to `develop`

5. Delete feature branch

### Release Flow

1. Create a release branch from `develop`
   ```bash
   git checkout develop
   git pull
   git checkout -b release/1.2.0
   ```

2. Make release-specific changes
   ```bash
   # Update version numbers, etc.
   git add .
   git commit -m "chore(release): bump version to 1.2.0"
   git push -u origin release/1.2.0
   ```

3. Create PR to `staging`

4. After testing in staging, create PR from `staging` to `main`

5. After approval, merge to `main`

6. Tag the release
   ```bash
   git checkout main
   git pull
   git tag -a v1.2.0 -m "Version 1.2.0"
   git push origin v1.2.0
   ```

7. Merge changes back to `develop`

### Hotfix Flow

1. Create a hotfix branch from `main`
   ```bash
   git checkout main
   git pull
   git checkout -b hotfix/456-fix-payment-calculation
   ```

2. Fix the issue
   ```bash
   # Make changes...
   git add .
   git commit -m "fix(payment): correct calculation formula"
   git push -u origin hotfix/456-fix-payment-calculation
   ```

3. Create PR to `main`

4. After approval, merge to `main`

5. Tag the hotfix
   ```bash
   git checkout main
   git pull
   git tag -a v1.2.1 -m "Hotfix: Fix payment calculation"
   git push origin v1.2.1
   ```

6. Merge changes to `develop` and `staging`

## Environment Deployment

| Branch    | Environment | Deployment Trigger | Approval Required |
|-----------|-------------|-------------------|------------------|
| `main`    | Production  | Manual            | Yes (Lead)       |
| `staging` | Staging     | Manual            | Yes (QA)         |
| `develop` | Development | Automatic         | No               |

---

This branching strategy is designed to support continuous integration and delivery while maintaining stability in production. It may be adjusted as the project evolves and the team identifies improvements.
