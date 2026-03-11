# frozen_string_literal: true

# Stub StripePayoutProcessor.stripe_balance_negative? globally so payout-related
# specs don't make unexpected Stripe::Balance.retrieve API calls.
# Tests that specifically exercise the negative-balance logic should override
# this with `allow(StripePayoutProcessor).to receive(:stripe_balance_negative?).and_call_original`.
RSpec.configure do |config|
  config.before(:each) do
    allow(StripePayoutProcessor).to receive(:stripe_balance_negative?).and_return(false)
  end
end
