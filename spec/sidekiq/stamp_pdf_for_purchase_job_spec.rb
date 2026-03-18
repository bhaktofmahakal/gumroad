# frozen_string_literal: true

require "spec_helper"

describe StampPdfForPurchaseJob do
  let(:seller) { create(:named_seller) }
  let(:product) { create(:product, user: seller) }
  let(:purchase) { create(:purchase, link: product, seller: seller) }

  before do
    allow(PdfStampingService).to receive(:stamp_for_purchase!)
  end

  it "has unique_across_queues enabled to prevent duplicate jobs on different queues" do
    expect(described_class.sidekiq_options["unique_across_queues"]).to eq(true)
  end

  it "performs the job" do
    described_class.new.perform(purchase.id)
    expect(PdfStampingService).to have_received(:stamp_for_purchase!).with(purchase)
  end

  it "sends files ready email when notify buyer cache flag is set" do
    purchase.create_url_redirect!
    Rails.cache.write(PdfStampingService.notify_buyer_cache_key(purchase.id), true)

    expect do
      described_class.new.perform(purchase.id)
    end.to have_enqueued_mail(CustomerMailer, :files_ready_for_download).with(purchase.id)

    expect(Rails.cache.read(PdfStampingService.notify_buyer_cache_key(purchase.id))).to be_nil
  end

  it "does not send files ready email when notify buyer cache flag is not set" do
    purchase.create_url_redirect!

    expect do
      described_class.new.perform(purchase.id)
    end.not_to have_enqueued_mail(CustomerMailer, :files_ready_for_download)
  end

  context "when stamping the PDFs fails with a known error" do
    before do
      allow(PdfStampingService).to receive(:stamp_for_purchase!).and_raise(PdfStampingService::Error)
    end

    it "raises the error so Sidekiq retries" do
      expect { described_class.new.perform(purchase.id) }.to raise_error(PdfStampingService::Error)
    end
  end

  context "when stamping the PDFs fails with an unknown error" do
    before do
      allow(PdfStampingService).to receive(:stamp_for_purchase!).and_raise(StandardError)
    end

    it "raises the error" do
      expect { described_class.new.perform(purchase.id) }.to raise_error(StandardError)
    end
  end
end
