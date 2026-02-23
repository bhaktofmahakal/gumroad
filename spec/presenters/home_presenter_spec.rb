# frozen_string_literal: true

require "spec_helper"

describe HomePresenter do
  subject(:presenter) { described_class.new }

  describe "#about_props" do
    it "returns the expected props" do
      props = presenter.about_props

      expect(props[:prev_week_payout]).to be_a(String)
      expect(props[:gumhead_animation_data]).to be_present
      expect(props[:discovery_rows]).to be_present
      expect(props[:testimonials]).to be_present
      expect(props[:assets]).to be_present
    end

    it "formats prev_week_payout with delimiters" do
      allow($redis).to receive(:get).with(RedisKey.prev_week_payout_usd).and_return("1234567")

      props = presenter.about_props

      expect(props[:prev_week_payout]).to eq("1,234,567")
    end

    it "uses default value when redis returns nil" do
      allow($redis).to receive(:get).with(RedisKey.prev_week_payout_usd).and_return(nil)

      props = presenter.about_props

      expect(props[:prev_week_payout]).to eq("3,129,297")
    end

    it "returns discovery rows as InertiaRails.once callable" do
      props = presenter.about_props

      expect(props[:discovery_rows]).to respond_to(:call)
    end

    it "returns testimonials as InertiaRails.once callable" do
      props = presenter.about_props

      expect(props[:testimonials]).to respond_to(:call)
    end

    it "returns assets as InertiaRails.once callable" do
      props = presenter.about_props

      expect(props[:assets]).to respond_to(:call)
    end
  end
end
