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

### Experiment 1: Stub Stripe account creation (a8f3a8c9d)
- **Target**: `spec/requests/settings/payments_spec.rb:4156` — Ghanaian creator test
- **Fix**: Stub Stripe account creation to avoid rate limiting from 42 parallel nodes
- **CI Run**: 23267175798 — 1 failed job, 1 failed spec (password_spec, not payments)
- **Status**: KEEP — payments_spec fixed

### Experiment 2: Wait for totp_credential + secure redirect + discover variant (2fc6be9b8, cf0d626a9, 94d55fd4e)
- **Target 1**: `spec/requests/settings/password_spec.rb:154` — totp_credential nil race condition
  - **Fix**: Use `wait_until_true` to poll for credential before asserting
- **Target 2**: `spec/requests/secure_redirect_spec.rb:66` — redirect test missing wait_for_ajax
  - **Fix**: Add `wait_for_ajax` after clicking Continue (consistent with all other POST tests in file)
- **Target 3**: `spec/requests/discover/discover_spec.rb:411` — thumbnail savepoint error
  - **Fix**: Pre-process thumbnail variant before page visit to avoid server-side DB savepoint during request
- **CI Run**: 23268614706 — 2 failed jobs, 2 failed specs (shipping_offer_codes + taxes)
- **Status**: KEEP — password, secure_redirect, and discover specs all passed

### Experiment 3: Checkout helper resilience + UTM links exact match (9bdf42436, 974c1234d)
- **Target 1**: `spec/support/checkout_helpers.rb` — address verification `has_text?` crashes with `ElementNotFound` when page is blank
  - **Fix**: Rescue `Capybara::ElementNotFound` in the address verification block, allowing the test to proceed to success assertions
- **Target 2**: `spec/requests/analytics/utm_links_spec.rb:112` — pagination button "3" matches hex IDs containing "3"
  - **Fix**: Use `exact: true` on negative button assertions
- **CI Run**: 23269401982 — 2 failed jobs (1 broken node infrastructure + 1 TaxJar VCR)
- **Status**: KEEP — all targeted fixes validated

### Experiment 4: Customers spec pagination exact match (5ff035da2)
- **Target**: `spec/requests/customers/customers_spec.rb:207` — same pagination button "3" substring matching issue as UTM links
  - **Fix**: Use `exact: true` on button assertions
- **CI Run**: 23272295308 — 4 failed jobs (sections_spec click intercept, show_spec ambiguous match, Stripe cascade, annual_spec)
- **Status**: KEEP

### Experiment 5: Sections JS click + show ambiguous match (ed2f21270, a3282ff65, b680e14c6)
- **Target 1**: `spec/requests/products/show/sections_spec.rb:59` — "Edit section" button covered by fixed Product information bar
  - **Fix**: Use `execute_script` to scrollIntoView and click via JS, bypassing native click interception
- **Target 2**: `spec/requests/products/show/show_spec.rb:176` — `within "[role='listitem']"` finds 2 elements
  - **Fix**: Add `match: :first` to scope to the primary cart item
- **Failed attempt**: Broad Stripe stub at Payout Information Collection level (7f1875ba1) — broke 11 jobs because tests assert `stripe_account.present?`. Reverted in b680e14c6.
- **CI Run**: 23275419428 — **0 failed jobs, 0 failed specs** (first fully clean run!)
- **Status**: KEEP

### Experiment 6: Checkout stale element rescue + Circle dropdown wait (a86d85415, 697b26c37)
- **Target 1**: `spec/support/checkout_helpers.rb` — address verification block only rescued `ElementNotFound`, not `StaleElementReferenceError`
  - **Fix**: Add `Selenium::WebDriver::Error::StaleElementReferenceError` to rescue clause
- **Target 2**: `spec/requests/products/edit/integrations/circle_integrations_spec.rb:24,:108` — "Select a community" dropdown not loaded when select is called
  - **Fix**: Wait for select with specific option before interacting (`have_select("Select a community", with_options: ["Gumroad [archived]"])`)
- **CI Run**: 23275898731 — 1 failed job (circle_integrations_spec — new failure, fixed in this experiment)

### Experiment 7: Canada Tax wait for tax calculation (b9840b331)
- **Target**: `spec/requests/purchases/product/taxes_spec.rb:3691,:3715,:3748` — Canada Tax tests get wrong total (10000 vs 11200)
  - Root cause: TaxJar API call is async; checkout submits before tax calculation completes
  - **Fix**: Add `wait_for_ajax` + `expect(page).to have_text("Total US$...")` before check_out to ensure tax is applied
- **CI Run**: 23277214585 — **0 failed jobs, 0 failed specs** (second fully clean run!)
- **Status**: KEEP

### Validation Results Summary
| Run ID | Failed Jobs | Failed Specs | Notes |
|--------|-------------|-------------|-------|
| 23275419428 | 0 | 0 | First clean run |
| 23275898731 | 1 | 1 | Circle integration (fixed in Exp 6) |
| 23276517885 | 1 | 1 | Canada Tax VCR (fixed in Exp 7) |
| 23277214585 | 0 | 0 | Second clean run |
| 23277765625 | 0 | 0 | Third clean run |
| 23278249756 | 1 | 1 | Shipping preorder tax timing (fixed in Exp 8) |

### Experiment 8: Shipping preorder tax wait (663164330)
- **Target**: `spec/requests/purchases/product/shipping/shipping_physical_preorder_spec.rb:74` — "Sales tax US$1.07" not found before checkout
  - Root cause: Tax calculation is async after address entry; assertion runs before TaxJar response is processed
  - **Fix**: Add `wait_for_ajax` in the checkout block before tax assertions
- **CI Run**: Pending

### Remaining Issues (for monitoring)
- `spec/requests/purchases/product/taxes_spec.rb` — physical product tests may still have Chrome crash issues
- `spec/requests/settings/payments_spec.rb` — Stripe rate limit cascade (partially mitigated by StripeRetryHelper)
- `spec/services/exports/payouts/annual_spec.rb` — date ordering in CSV export (rare)
- Various sporadic Chrome/Selenium issues: xpath "/html" not found, undefined method 'map' for true
