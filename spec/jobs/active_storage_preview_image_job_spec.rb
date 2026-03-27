# frozen_string_literal: true

require "spec_helper"

describe ActiveStorage::PreviewImageJob do
  it "discards the job when ActiveStorage::PreviewError is raised" do
    allow_any_instance_of(described_class).to receive(:perform).and_raise(ActiveStorage::PreviewError, "ffmpeg failed (status 1)")

    expect do
      described_class.perform_now("fake_blob_id")
    end.not_to raise_error
  end

  it "logs a warning when discarding due to PreviewError" do
    allow_any_instance_of(described_class).to receive(:perform).and_raise(ActiveStorage::PreviewError, "ffmpeg failed (status 1)")
    allow(Rails.logger).to receive(:warn)

    described_class.perform_now("fake_blob_id")

    expect(Rails.logger).to have_received(:warn).with(/Discarding PreviewImageJob.*ffmpeg failed/)
  end
end
