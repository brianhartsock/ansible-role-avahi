# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible role (`brianhartsock.avahi`) that installs and configures Avahi (mDNS/Bonjour service discovery) on Debian/Ubuntu systems. Published to Ansible Galaxy.

## Common Commands

### Install dependencies
```
uv sync
```

### Linting
```
uv run ansible-lint
uv run yamllint .
uv run flake8 molecule/default/tests/
```

### Run tests (requires Docker)
```
uv run molecule test                          # default scenario (Ubuntu 22.04 + 24.04)
uv run molecule test -s check_mode            # check_mode scenario (Ubuntu 24.04)
```

### Run individual molecule stages
```
uv run molecule converge                      # apply the role
uv run molecule verify                        # run testinfra tests only
uv run molecule destroy                       # tear down containers
uv run molecule login                         # shell into test container
```

## Architecture

- **defaults/main.yml** — Role variables (services list, network config, IPv6, reflector, dbus, additional packages)
- **vars/Debian.yml** — OS-family-specific variables loaded via `include_vars` with `ansible_os_family`
- **tasks/main.yml** — Linear task flow: load OS vars → install package → template daemon config → template service files → ensure service running
- **templates/avahi-daemon.conf.j2** — Daemon configuration (server, publish, reflector, rlimits sections)
- **templates/service.j2** — XML service definition template; iterated over `avahi_services` list, each producing `/etc/avahi/services/<name>.service`
- **handlers/main.yml** — Single "Restart Avahi" handler, notified on config/service file changes

Service restart and start tasks skip in `check_mode` to avoid failures in dry-run testing.

## Testing

Molecule uses Docker with `geerlingguy/docker-*-ansible` images. Tests are in `molecule/default/tests/test_default.py` using pytest-testinfra. Two scenarios exist: `default` (full converge + idempotence on jammy/noble) and `check_mode` (dry-run on noble, no idempotence check).

## CI

GitHub Actions runs lint (ansible-lint, yamllint, flake8) and both molecule scenarios on PRs and pushes to master. Releases to Ansible Galaxy are triggered by GitHub release events.

## Development Workflow

Follow this workflow for all code changes.

```
Code → Document → Verify → Code Review
  ^                              |
  └──── fix issues ──────────────┘
```

### 1. Code

Make the implementation changes. Use FQCNs, name all tasks, and follow the patterns in existing task files.

### 2. Document

Update README.md and CLAUDE.md to reflect any changes to variables, platforms, commands, or architecture. If the ansible plugin is installed, use the `documentator` agent.

### 3. Verify

Run linters (yamllint, ansible-lint, flake8), pre-commit hooks, and molecule tests. All checks must pass before proceeding. If the ansible plugin is installed, use the `verifier` agent.

### 4. Code Review

Review the changes for Ansible best practices, idempotency, security, cross-platform correctness, and test coverage. If the ansible plugin is installed, use the `code-reviewer` agent.

### 5. Iterate

If verification or code review flags issues, fix them and repeat from step 2. Continue until all checks pass and the review is clean.
