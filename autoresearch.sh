#!/usr/bin/env bash
set -euo pipefail

# Autoresearch: Flaky Tests
# Pushes current branch, waits for CI, counts failures.
# Outputs METRIC lines for autoresearch tooling.

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse --short HEAD)

echo "=== Pushing $BRANCH ($COMMIT) ==="
git push origin "$BRANCH" --force-with-lease 2>&1

echo "=== Waiting for CI to start ==="
sleep 15

# Find the Tests workflow run for this commit
RUN_ID=""
for i in $(seq 1 20); do
  RUN_ID=$(gh run list --branch "$BRANCH" --workflow "Tests" --limit 1 --json databaseId,headSha --jq ".[0] | select(.headSha | startswith(\"$(git rev-parse HEAD | cut -c1-7)\")) | .databaseId" 2>/dev/null || true)
  if [[ -n "$RUN_ID" ]]; then
    break
  fi
  echo "Waiting for run to appear... ($i/20)"
  sleep 10
done

if [[ -z "$RUN_ID" ]]; then
  echo "ERROR: Could not find CI run for commit $COMMIT"
  echo "METRIC failed_jobs=99"
  echo "METRIC failed_specs=99"
  exit 1
fi

echo "=== Found run $RUN_ID, watching ==="
gh run watch "$RUN_ID" --exit-status 2>&1 || true

# Count failed jobs
FAILED_JOBS=$(gh run view "$RUN_ID" --json jobs --jq '[.jobs[] | select(.conclusion == "failure")] | length')
TOTAL_JOBS=$(gh run view "$RUN_ID" --json jobs --jq '[.jobs[] | select(.name | startswith("Test"))] | length')

# Count unique failed spec files
FAILED_SPECS=0
if [[ "$FAILED_JOBS" -gt 0 ]]; then
  FAILED_SPECS=$(gh run view "$RUN_ID" --log-failed 2>&1 | grep "^.*rspec \./spec" | sed 's/.*rspec //' | sed 's/:[0-9]* .*//' | sort -u | wc -l | tr -d ' ')
fi

echo ""
echo "=== Results ==="
echo "Run: $RUN_ID"
echo "Failed jobs: $FAILED_JOBS / $TOTAL_JOBS"
echo "Failed specs: $FAILED_SPECS"
echo ""
echo "METRIC failed_jobs=$FAILED_JOBS"
echo "METRIC failed_specs=$FAILED_SPECS"
