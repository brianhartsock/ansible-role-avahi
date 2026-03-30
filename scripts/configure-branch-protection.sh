#!/usr/bin/env bash
#
# Configures branch protection on master with required status checks (Lint, Molecule).
# Required for gh pr merge --auto to wait for CI before merging.
#
# Usage: ./scripts/configure-branch-protection.sh [--check]
#   --check   Only check current settings, don't modify anything
#
set -euo pipefail

REPO="brianhartsock/ansible-role-avahi"
BRANCH="master"
REQUIRED_CHECKS=("Lint" "Molecule")

check_current() {
    echo "Fetching branch protection for $BRANCH..."
    protection=$(gh api "repos/$REPO/branches/$BRANCH/protection" 2>&1) || {
        echo "No branch protection configured on $BRANCH."
        return 1
    }

    checks=$(echo "$protection" | jq -r '.required_status_checks.checks // []')
    if [ "$checks" = "[]" ] || [ -z "$checks" ]; then
        echo "Branch protection exists but no required status checks are configured."
        return 1
    fi

    echo "Current required status checks:"
    echo "$protection" | jq -r '.required_status_checks.checks[].context'

    missing=0
    for check in "${REQUIRED_CHECKS[@]}"; do
        if ! echo "$protection" | jq -r '.required_status_checks.checks[].context' | grep -qx "$check"; then
            echo "Missing required check: $check"
            missing=1
        fi
    done

    if [ "$missing" -eq 0 ]; then
        echo "All required checks are configured."
        return 0
    fi
    return 1
}

configure() {
    echo "Configuring branch protection on $BRANCH..."

    # Build the checks array for the API
    checks_json=$(printf '%s\n' "${REQUIRED_CHECKS[@]}" | jq -R '{"context": ., "app_id": -1}' | jq -s '.')

    gh api --method PUT "repos/$REPO/branches/$BRANCH/protection" \
        --input <(jq -n \
            --argjson checks "$checks_json" \
            '{
                required_status_checks: {
                    strict: false,
                    checks: $checks
                },
                enforce_admins: false,
                required_pull_request_reviews: null,
                restrictions: null
            }')

    echo "Branch protection configured with required checks: ${REQUIRED_CHECKS[*]}"
}

if [ "${1:-}" = "--check" ]; then
    check_current
else
    if check_current; then
        echo "Nothing to do."
    else
        configure
        echo ""
        echo "Verifying..."
        check_current
    fi
fi
