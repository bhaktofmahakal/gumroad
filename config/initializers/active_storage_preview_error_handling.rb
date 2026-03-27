# frozen_string_literal: true

Rails.application.config.after_initialize do
  ActiveStorage::PreviewImageJob.discard_on(ActiveStorage::PreviewError) do |job, error|
    Rails.logger.warn("[ActiveStorage] Discarding PreviewImageJob: #{error.message}")
  end
end
