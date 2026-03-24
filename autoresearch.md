# Autoresearch: Fix flaky Dropbox test — 5 consecutive green CI runs

## Metrics
- **Primary**: consecutive_greens (unitless, higher is better)

## How to Run
`autoresearch.sh` — should emit `METRIC name=number` lines for consecutive_greens.

## What's Been Tried
- #2 crash 1 7179dd2 — CI infra failure: git checkout failed due to .claude/worktrees submodule path in .gitmodules. Not a test failure.
- #3 crash 1 7179dd2 — Same CI infra failure on rerun — .claude/worktrees tracked as git submodules breaks checkout
- #4 keep 2 595e970 — CI run 2 green (also fixed .claude/worktrees blocking checkout)
- #5 discard 0 3d0a8b0 — CI run 3: different flaky test failed (embed_spec.rb:114 - affiliate embed). Not related to our fix.
- #6 crash 0 8ff94f1 — CI run 4: webpack build failure in CI (empty manifest.json). Not a test failure — CI infra issue.
- #7 keep 1 d9a0786 — CI run 5: green (1st consecutive after reset)
- #8 keep 2 9888ac1 — CI run 6: green (2nd consecutive)
- #9 keep 3 9a77c55 — CI run 7: green (3rd consecutive)

## Plugin Checkpoint
- Last updated: 2026-03-24T23:06:42.102Z
- Runs tracked: 9 current / 9 total
- Baseline: 1
- Best kept: 3
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #9 keep 9a77c55 — CI run 7: green (3rd consecutive)
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23515965864 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 9 current / 9 total
- Baseline: 1
- Best kept: 3
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #9 keep 9a77c55 — CI run 7: green (3rd consecutive)

Z
- Runs tracked: 8 current / 8 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #8 keep 9888ac1 — CI run 6: green (2nd consecutive)
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23515391695 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 8 current / 8 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #8 keep 9888ac1 — CI run 6: green (2nd consecutive)

Z
- Runs tracked: 7 current / 7 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #7 keep d9a0786 — CI run 5: green (1st consecutive after reset)
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23514702175 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 7 current / 7 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #7 keep d9a0786 — CI run 5: green (1st consecutive after reset)

Z
- Runs tracked: 6 current / 6 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #6 crash 8ff94f1 — CI run 4: webpack build failure in CI (empty manifest.json). Not a test failure — CI infra issue.
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23514016240 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 6 current / 6 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #6 crash 8ff94f1 — CI run 4: webpack build failure in CI (empty manifest.json). Not a test failure — CI infra issue.

Z
- Runs tracked: 5 current / 5 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #5 discard 3d0a8b0 — CI run 3: different flaky test failed (embed_spec.rb:114 - affiliate embed). Not related to our fix.
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23513149268 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 5 current / 5 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #5 discard 3d0a8b0 — CI run 3: different flaky test failed (embed_spec.rb:114 - affiliate embed). Not related to our fix.

Z
- Runs tracked: 4 current / 4 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #4 keep 595e970 — CI run 2 green (also fixed .claude/worktrees blocking checkout)
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23512402858 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 4 current / 4 total
- Baseline: 1
- Best kept: 2
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #4 keep 595e970 — CI run 2 green (also fixed .claude/worktrees blocking checkout)

Z
- Runs tracked: 3 current / 3 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #3 crash 7179dd2 — Same CI infra failure on rerun — .claude/worktrees tracked as git submodules breaks checkout
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23511684369 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 3 current / 3 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #3 crash 7179dd2 — Same CI infra failure on rerun — .claude/worktrees tracked as git submodules breaks checkout

Z
- Runs tracked: 2 current / 2 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #2 crash 7179dd2 — CI infra failure: git checkout failed due to .claude/worktrees submodule path in .gitmodules. Not a test failure.
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23511594343 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 2 current / 2 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #2 crash 7179dd2 — CI infra failure: git checkout failed due to .claude/worktrees submodule path in .gitmodules. Not a test failure.

Z
- Runs tracked: 1 current / 1 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #1 keep 6f47c49 — First CI run with fix: batch ID mappings in save_files! to prevent transitive collision
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23511594343 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 1 current / 1 total
- Baseline: 1
- Best kept: 1
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Last logged run: #1 keep 6f47c49 — First CI run with fix: batch ID mappings in save_files! to prevent transitive collision

Z
- Runs tracked: 0 current / 0 total
- Baseline: n/a
- Best kept: n/a
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
- Pending run awaiting log_experiment: cd /Users/gumclaw/.openclaw/workspace/repos/gumroad && gh run watch 23510795802 --exit-status 2>&1; echo "EXIT_CODE=$?" (n/a)

Z
- Runs tracked: 0 current / 0 total
- Baseline: n/a
- Best kept: n/a
- Confidence: n/a
- Canonical branch: fix/flaky-dropbox-test
