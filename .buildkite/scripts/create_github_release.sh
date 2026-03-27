#!/bin/bash
set -e

GREEN="\033[0;32m"
NC="\033[0m"
logger() {
  echo -e "${GREEN}$(date "+%Y/%m/%d %H:%M:%S") create_github_release.sh: $1${NC}"
}

COMMIT_SHA=${BUILDKITE_COMMIT}

# Determine calendar version tag (vYYYY.MM.DD.N)
TODAY=$(date -u +%Y.%m.%d)

# Fetch existing tags for today to determine sequence number
git fetch --tags --force > /dev/null 2>&1
EXISTING_TAGS=$(git tag -l "v${TODAY}.*" | sort -t. -k4 -n)

if [ -z "$EXISTING_TAGS" ]; then
  SEQUENCE=1
else
  LAST_SEQUENCE=$(echo "$EXISTING_TAGS" | tail -1 | rev | cut -d. -f1 | rev)
  SEQUENCE=$((LAST_SEQUENCE + 1))
fi

VERSION_TAG="v${TODAY}.${SEQUENCE}"

# Find the previous release tag for changelog range
PREVIOUS_TAG=$(git tag -l "v*.*.*.*" | sort -t. -k1,1 -k2,2n -k3,3n -k4,4n | tail -1)

logger "Creating GitHub Release ${VERSION_TAG} at commit ${COMMIT_SHA}"

# Create and push the git tag
git tag "$VERSION_TAG" "$COMMIT_SHA"
git push origin "$VERSION_TAG"

# Build the gh release create command
RELEASE_CMD="gh release create ${VERSION_TAG} --target ${COMMIT_SHA} --generate-notes"

if [ -n "$PREVIOUS_TAG" ]; then
  logger "Generating changelog from ${PREVIOUS_TAG} to ${VERSION_TAG}"
  RELEASE_CMD+=" --notes-start-tag ${PREVIOUS_TAG}"
fi

eval "$RELEASE_CMD"

logger "GitHub Release ${VERSION_TAG} created successfully"
