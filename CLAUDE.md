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

- **defaults/main.yml** — Role variables (services list, network config, IPv6, reflector, dbus)
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
