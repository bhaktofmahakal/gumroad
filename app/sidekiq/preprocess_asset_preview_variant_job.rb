# frozen_string_literal: true

class PreprocessAssetPreviewVariantJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 3

  def perform(asset_preview_id)
    asset_preview = AssetPreview.find_by(id: asset_preview_id)
    return unless asset_preview&.should_post_process? && asset_preview.file.attached?

    asset_preview.retina_variant
    # Warm the URL cache after processing
    Rails.cache.delete("attachment_#{asset_preview.file.id}_retina_url")
  end
end
