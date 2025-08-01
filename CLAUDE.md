# Metabase Description Generator - Development Guide

## =� Project Context & Architecture

**Project**: AI-powered Metabase question description generator with visual tree interface
**Stack**: Next.js 14, TypeScript, Express, PostgreSQL, OpenAI/Claude API
**Architecture**: Full-stack TypeScript monorepo with Docker containerization

### Key Design Principles
- **Design-First**: Complete all architectural artifacts before coding
- **Type Safety**: End-to-end TypeScript with strict validation
- **Security by Default**: JWT + RBAC, encrypted credentials, audit logging
- **Performance First**: Sub-second response times, 1000+ question support
- **Production Ready**: Docker, monitoring, CI/CD, comprehensive testing

---

## =� Git Workflow Strategy

### Branch Strategy (GitHub Flow with Feature Isolation)

```
main (production-ready)
   develop (integration branch)
   feature/api-design (Days 1-3 design work)
   feature/database-schema (Days 1-3 design work)
   feature/frontend-components (Days 4-5 design work)
   feature/auth-system (Phase 1 implementation)
   feature/metabase-integration (Phase 3 implementation)
   feature/ai-service (Phase 4 implementation)
   hotfix/security-patch (emergency fixes)
```

### Branch Naming Conventions

**Design Phase Branches:**
- `design/api-specification` - OpenAPI spec and TypeScript types
- `design/database-schema` - Database migrations and models
- `design/system-architecture` - Documentation and diagrams
- `design/component-system` - Frontend component architecture

**Implementation Phase Branches:**
- `feature/auth-jwt-rbac` - Authentication and authorization
- `feature/metabase-api-client` - External API integration
- `feature/ai-description-engine` - AI service integration
- `feature/tree-view-component` - Core UI components
- `feature/bulk-operations` - Background job processing

**Infrastructure Branches:**
- `infra/docker-setup` - Container configuration
- `infra/ci-cd-pipeline` - GitHub Actions workflows
- `infra/monitoring-setup` - Observability and logging

**Bug Fix Branches:**
- `fix/api-validation-bug` - Non-critical bug fixes
- `hotfix/security-vulnerability` - Critical security issues

### Commit Message Standards

**Format**: `<type>(<scope>): <description>`

**Types:**
- `feat`: New feature or enhancement
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic changes)
- `refactor`: Code restructuring (no functionality changes)
- `test`: Adding or updating tests
- `chore`: Build process, dependency updates
- `security`: Security-related changes
- `perf`: Performance improvements

**Scopes:**
- `api`: Backend API changes
- `ui`: Frontend components and UI
- `db`: Database schema or migrations
- `auth`: Authentication and authorization
- `ai`: AI service integration
- `docs`: Documentation updates
- `infra`: Infrastructure and deployment
- `test`: Testing-related changes

**Examples:**
```bash
feat(api): add OpenAPI specification for description endpoints
feat(db): create database migration for RBAC user roles
feat(ui): implement tree-view component with virtual scrolling
fix(auth): resolve JWT token refresh race condition
docs(api): update authentication flow documentation
chore(deps): upgrade Next.js to version 14.1
security(auth): implement rate limiting for login attempts
perf(api): add Redis caching for Metabase API responses
```

### Work Tree Management Strategy

**Parallel Development Approach:**
```bash
# Main repository for integration
git clone https://github.com/org/metabase-descriptor.git
cd metabase-descriptor

# Design phase work trees (parallel work)
git worktree add ../design-api design/api-specification
git worktree add ../design-db design/database-schema
git worktree add ../design-frontend design/component-system

# Implementation phase work trees
git worktree add ../feature-auth feature/auth-jwt-rbac
git worktree add ../feature-ai feature/ai-description-engine
git worktree add ../feature-ui feature/tree-view-component

# Infrastructure work trees
git worktree add ../infra-docker infra/docker-setup
git worktree add ../infra-ci infra/ci-cd-pipeline
```

**Benefits:**
-  Multiple features in parallel without context switching
-  Isolated dependencies and node_modules per work tree
-  Faster development with reduced git checkout overhead
-  Easy testing of feature combinations

**Work Tree Workflow:**
```bash
# Switch between work trees instantly
cd ../design-api        # Work on OpenAPI specification
cd ../feature-auth      # Implement JWT authentication
cd ../feature-ui        # Build React components
cd ../metabase-descriptor  # Integration and testing

# Clean up completed work trees
git worktree remove ../design-api
git worktree prune
```

### Merge Strategy

**Design Phase Merges:**
```bash
# Merge design artifacts to develop first
git checkout develop
git merge --no-ff design/api-specification
git merge --no-ff design/database-schema
git merge --no-ff design/component-system

# Then merge to main after design review
git checkout main
git merge --no-ff develop
```

**Feature Development Merges:**
```bash
# Feature branch workflow with Pull Requests
git checkout develop
git pull origin develop
git checkout -b feature/auth-jwt-rbac

# Development work...
git add .
git commit -m "feat(auth): implement JWT with refresh tokens"
git push origin feature/auth-jwt-rbac

# Create Pull Request to develop branch
# After review and CI passes, squash merge to develop
```

**Production Releases:**
```bash
# Release from develop to main
git checkout main
git merge --no-ff develop
git tag -a v1.0.0 -m "Release version 1.0.0: Initial MVP"
git push origin main --tags
```

### Pre-commit Hooks (Husky + lint-staged)

**Setup:**
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS",
      "pre-push": "npm run test:ci"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "git add"
    ],
    "*.{js,jsx,ts,tsx}": [
      "npm run test:related"
    ],
    "docs/*.md": [
      "markdownlint --fix",
      "git add"
    ]
  }
}
```

**Commit Linting:**
```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor', 
      'test', 'chore', 'security', 'perf'
    ]],
    'scope-enum': [2, 'always', [
      'api', 'ui', 'db', 'auth', 'ai', 'docs', 'infra', 'test'
    ]]
  }
};
```

---

## =� Development Best Practices

### Code Quality Standards

**TypeScript Configuration:**
```json
// tsconfig.json (strict configuration)
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**ESLint Rules:**
```json
// .eslintrc.json
{
  "extends": [
    "@next/eslint-config-next",
    "@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "prefer-const": "error",
    "no-console": "warn"
  }
}
```

### Security Best Practices

**Environment Variables:**
```bash
# .env.example
DATABASE_URL=postgresql://user:pass@localhost:5432/metabase_desc
JWT_SECRET=your-256-bit-secret
JWT_REFRESH_SECRET=your-256-bit-refresh-secret
METABASE_API_KEY=encrypted-credential
OPENAI_API_KEY=sk-your-api-key
REDIS_URL=redis://localhost:6379
```

**Credential Encryption:**
```typescript
// utils/encryption.ts
import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const KEY = crypto.scryptSync(process.env.ENCRYPTION_KEY!, 'salt', 32);

export function encrypt(text: string): string {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipher(ALGORITHM, KEY);
  // Implementation...
}
```

### Testing Strategy

**Test Structure:**
```
tests/
   unit/           # Component and function tests
   integration/    # API endpoint tests
   e2e/           # Full user workflow tests
   fixtures/      # Test data and mocks
```

**Test Commands:**
```json
// package.json scripts
{
  "test": "jest",
  "test:watch": "jest --watch",
  "test:coverage": "jest --coverage",
  "test:e2e": "playwright test",
  "test:ci": "jest --ci --coverage --watchAll=false"
}
```

### Performance Monitoring

**Key Metrics to Track:**
- API response times (< 200ms target)
- Database query performance (< 100ms target)  
- AI generation latency (< 5s target)
- Frontend bundle size (< 500KB initial)
- Memory usage (< 100MB backend, < 50MB frontend)

---

## =' Development Commands

### Essential Git Commands

**Daily Workflow:**
```bash
# Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# Commit work
git add .
git commit -m "feat(scope): descriptive message"

# Update with latest changes
git fetch origin
git rebase origin/develop

# Push feature branch
git push origin feature/new-feature

# Clean up after merge
git checkout develop
git pull origin develop
git branch -d feature/new-feature
git remote prune origin
```

**Work Tree Management:**
```bash
# List all work trees
git worktree list

# Add new work tree
git worktree add ../feature-name feature/branch-name

# Remove work tree
git worktree remove ../feature-name
git worktree prune

# Move work tree
git worktree move ../old-location ../new-location
```

**Advanced Git Operations:**
```bash
# Interactive rebase for clean history
git rebase -i HEAD~3

# Cherry-pick specific commits
git cherry-pick abc123def

# Stash with message
git stash push -m "Work in progress on auth system"

# Create and apply patches
git format-patch HEAD~2
git apply 0001-feature-patch.patch
```

### Development Environment

**Quick Setup:**
```bash
# Clone repository
git clone https://github.com/org/metabase-descriptor.git
cd metabase-descriptor

# Install dependencies
npm install

# Setup environment
cp .env.example .env.local
# Edit .env.local with your credentials

# Start development environment
docker-compose -f docker-compose.dev.yml up -d
npm run dev

# Run tests
npm run test
```

**Database Operations:**
```bash
# Run migrations
npm run db:migrate

# Reset database
npm run db:reset

# Seed development data
npm run db:seed

# Generate new migration
npm run db:migration:create add_user_roles
```

---

## =� Architecture Decision Records (ADRs)

### ADR-001: Design-First Development Approach
**Status**: Accepted
**Decision**: Complete all design artifacts before implementation
**Rationale**: Prevents rework, enables parallel development, reduces integration risks
**Consequences**: Additional upfront time investment, but 2-3 weeks saved overall

### ADR-002: GitHub Flow with Work Trees
**Status**: Accepted  
**Decision**: Use GitHub Flow with git work trees for parallel development
**Rationale**: Enables multiple developers working on different features simultaneously
**Consequences**: Requires git work tree knowledge, but significantly faster development

### ADR-003: Strict TypeScript Configuration
**Status**: Accepted
**Decision**: Use strict TypeScript with explicit return types
**Rationale**: Prevents runtime errors, improves code documentation, better IDE support
**Consequences**: Longer initial development, but fewer bugs and better maintainability

---

## =� Emergency Procedures

### Hotfix Process
```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/critical-security-fix

# Make minimal changes
git commit -m "security(auth): fix JWT validation vulnerability"

# Test thoroughly
npm run test:ci
npm run test:e2e

# Merge to main and develop
git checkout main
git merge --no-ff hotfix/critical-security-fix
git tag -a v1.0.1 -m "Hotfix: Security vulnerability"

git checkout develop  
git merge --no-ff hotfix/critical-security-fix

# Deploy immediately
git push origin main --tags
git push origin develop
```

### Rollback Procedure
```bash
# Revert to previous version
git checkout main
git revert HEAD --no-edit
git push origin main

# Or reset to specific version
git reset --hard v1.0.0
git push --force-with-lease origin main
```

---

## =� Additional Resources

- **OpenAPI Specification**: `/docs/api-specification.yaml`
- **Database Schema**: `/database/migrations/`
- **Component Documentation**: `/docs/components/`
- **Security Guidelines**: `/docs/security/`
- **Deployment Guide**: `/docs/deployment/`

## <� Success Metrics

- **Development Velocity**: 70% faster feature delivery
- **Code Quality**: 90%+ test coverage, 0 critical security issues
- **Team Productivity**: 30-minute onboarding for new developers
- **Deployment Reliability**: 99.9% successful deployments
- **Performance**: Sub-second response times, <2MB bundle size