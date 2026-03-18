# Autoresearch: Fix Flaky CI Tests

## Objective
Reduce the number of flaky test failures in the Gumroad CI pipeline. Tests run on GitHub Actions via KnapsackPro across ~42 parallel nodes. Flaky tests cause nearly every CI run to fail, blocking merges and wasting developer time.

## Metrics
- **Primary**: `failed_jobs` (count, lower is better) — number of CI test jobs that fail per run
- **Secondary**: `failed_specs` — number of unique spec files that fail

## How to Run
`./autoresearch.sh` — pushes current branch, triggers CI, waits for completion, outputs `METRIC name=number` lines.

**Important:** Each run takes 15-25 minutes (CI pipeline time). This is not a fast loop.

## Top Flaky Tests (from analysis of last 15 CI runs on main)

### Critical — fails in every run:
1. `spec/requests/settings/payments_spec.rb:4156` — "Ghanaian creator allows to enter bank account details"
   - Root cause: Stripe rate limiting (`creating accounts too quickly`) when 42 parallel nodes all create Stripe test accounts simultaneously
   - Fix approach: mock/stub Stripe account creation, add retry with backoff, or reduce concurrent Stripe calls

### Recurring (3+ runs):
2. `spec/requests/discover/discover_spec.rb:411` — "displays thumbnail in preview if available"
3. `spec/requests/secure_redirect_spec.rb:66` — "POST /secure_url_redirect with correct confirmation text redirects to the destination"
4. `spec/requests/purchases/product/taxes_spec.rb` — various country tax tests (different ones each run, likely timing/ordering issue)

### Occasional (2 runs):
5. `spec/requests/purchases/product/shipping/shipping_spec.rb` — various shipping scenarios
6. `spec/requests/balance_pages_spec.rb` — payout display tests

## Files in Scope
- `spec/requests/settings/payments_spec.rb` — payment settings system tests (main offender)
- `spec/requests/discover/discover_spec.rb` — discover page tests
- `spec/requests/secure_redirect_spec.rb` — secure redirect tests
- `spec/requests/purchases/product/taxes_spec.rb` — tax calculation tests
- `spec/support/` — shared test helpers, Stripe mocks, Capybara config
- `spec/rails_helper.rb` — test configuration
- `spec/spec_helper.rb` — test configuration
- Any test support files related to Stripe stubbing

## Off Limits
- Application code (app/, lib/) — we're fixing tests, not changing behavior
- CI configuration (.github/workflows/) — don't change the pipeline structure
- Gemfile / dependencies — no new gems

## Constraints
- Tests must still test the same behavior (no deleting tests or weakening assertions)
- Changes must be backward-compatible with the existing CI setup (KnapsackPro, parallel nodes)
- Focus on one flaky test at a time, starting with the most impactful (#1)
- Each experiment = one fix attempt, pushed to branch, validated via CI

## What's Been Tried
(Nothing yet — this is the initial session)
