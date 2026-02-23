# frozen_string_literal: true

require "spec_helper"
require "inertia_rails/rspec"

describe HomeController, inertia: true do
  render_views

  describe "GET about" do
    it "renders successfully with expected props" do
      get :about

      expect(response).to be_successful
      expect(controller.send(:page_title)).to eq("Earn your first dollar online with Gumroad")
      expect(inertia.component).to eq("Home/About")
      expect(inertia.props[:prev_week_payout]).to be_a(String)
      expect(inertia.props[:gumhead_animation_data]).to be_present
      expect(inertia.props[:discovery_rows]).to be_present
      expect(inertia.props[:testimonials]).to be_present
      expect(inertia.props[:assets]).to be_present
    end

    it "excludes once props on subsequent Inertia requests when client has them cached" do
      request.headers["X-Inertia"] = "true"
      request.headers["X-Inertia-Partial-Component"] = "Home/About"
      request.headers["X-Inertia-Except-Once-Props"] = "gumhead_animation_data,discovery_rows,testimonials,assets"
      get :about

      expect(response).to be_successful
      expect(inertia.props[:gumhead_animation_data]).to be_nil
      expect(inertia.props[:discovery_rows]).to be_nil
      expect(inertia.props[:testimonials]).to be_nil
      expect(inertia.props[:assets]).to be_nil
    end
  end

  describe "GET small_bets" do
    it "renders successfully" do
      get :small_bets

      expect(response).to be_successful
      expect(controller.send(:page_title)).to eq("Small Bets by Gumroad")
      expect(assigns(:hide_layouts)).to be(true)
    end
  end
end
