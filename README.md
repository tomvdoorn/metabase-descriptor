# GitHub Manager Tool

A comprehensive command-line tool for managing GitHub issues and pull requests.

## Features

- **Issue Management**: List, create, update, close, and comment on issues
- **Pull Request Management**: List, create, merge, close, and comment on PRs
- **Filtering**: Filter issues and PRs by state, labels, assignees, and branches
- **Easy Configuration**: Uses environment variables for authentication

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Make the script executable:
```bash
chmod +x github_manager.py
```

3. (Optional) Install as a package:
```bash
pip install -e .
```

## Configuration

Set the following environment variables:

```bash
export GITHUB_TOKEN="your_github_personal_access_token"
export GITHUB_OWNER="repository_owner"
export GITHUB_REPO="repository_name"
```

### Creating a GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token"
3. Select scopes: `repo`, `read:org` (minimum required)
4. Copy the token and set it as `GITHUB_TOKEN`

## Usage

### Issue Management

```bash
# List open issues
python github_manager.py issue list

# List closed issues
python github_manager.py issue list --state closed

# Filter issues by labels
python github_manager.py issue list --labels "bug,enhancement"

# Get specific issue
python github_manager.py issue get 123

# Create new issue
python github_manager.py issue create "Bug in login system" --body "Login fails with error message" --labels "bug,urgent"

# Update issue
python github_manager.py issue update 123 --title "Updated title" --state closed

# Close issue
python github_manager.py issue close 123

# Add comment to issue
python github_manager.py issue comment 123 "This has been fixed in the latest release"
```

### Pull Request Management

```bash
# List open pull requests
python github_manager.py pr list

# List PRs for specific base branch
python github_manager.py pr list --base main

# Get specific PR
python github_manager.py pr get 456

# Create new PR
python github_manager.py pr create "Add new feature" feature-branch main --body "This PR adds a new feature"

# Create draft PR
python github_manager.py pr create "Work in progress" feature-branch main --draft

# Merge PR
python github_manager.py pr merge 456 --method squash

# Close PR
python github_manager.py pr close 456
```

## Command Reference

### Issue Commands

- `issue list [--state open|closed|all] [--labels LABELS] [--assignee USER]`
- `issue get NUMBER`
- `issue create TITLE [--body TEXT] [--labels LABELS] [--assignees USERS]`
- `issue update NUMBER [--title TITLE] [--body TEXT] [--state open|closed] [--labels LABELS]`
- `issue close NUMBER`
- `issue comment NUMBER COMMENT`

### Pull Request Commands

- `pr list [--state open|closed|all] [--base BRANCH] [--head BRANCH]`
- `pr get NUMBER`
- `pr create TITLE HEAD BASE [--body TEXT] [--draft]`
- `pr merge NUMBER [--method merge|squash|rebase] [--title TITLE] [--message MESSAGE]`
- `pr close NUMBER`

## Examples

### Workflow Examples

1. **Create and manage a bug report:**
```bash
# Create bug issue
python github_manager.py issue create "Login button not working" \
  --body "The login button doesn't respond when clicked on mobile devices" \
  --labels "bug,mobile,urgent"

# Add investigation comment
python github_manager.py issue comment 123 "Investigating the issue, seems related to CSS media queries"

# Close when fixed
python github_manager.py issue close 123
```

2. **Review and merge a pull request:**
```bash
# List pending PRs
python github_manager.py pr list

# Review specific PR
python github_manager.py pr get 456

# Merge with squash
python github_manager.py pr merge 456 --method squash --title "Fix mobile login issue"
```

3. **Batch operations:**
```bash
# List all open issues with specific labels
python github_manager.py issue list --labels "bug" --state open

# Close multiple issues (use in shell loop)
for issue in 123 124 125; do
  python github_manager.py issue close $issue
done
```

## Error Handling

The tool provides clear error messages for common issues:
- Missing authentication token
- Invalid repository access
- Network connectivity problems
- API rate limiting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.