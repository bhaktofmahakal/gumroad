# frozen_string_literal: true

describe PreprocessAssetPreviewVariantJob do
  describe "#perform" do
    it "processes the retina variant for an image asset preview" do
      asset_preview = create(:asset_preview)
      expect(asset_preview).to receive(:retina_variant).and_return(double(url: "https://example.com/retina.png"))
      allow(AssetPreview).to receive(:find_by).with(id: asset_preview.id).and_return(asset_preview)

      PreprocessAssetPreviewVariantJob.new.perform(asset_preview.id)
    end

    it "is a no-op for non-image files" do
      asset_preview = create(:asset_preview_mov)
      expect(asset_preview).not_to receive(:retina_variant)
      allow(AssetPreview).to receive(:find_by).with(id: asset_preview.id).and_return(asset_preview)

      PreprocessAssetPreviewVariantJob.new.perform(asset_preview.id)
    end

    it "is a no-op for missing asset previews" do
      expect { PreprocessAssetPreviewVariantJob.new.perform(0) }.not_to raise_error
    end
  end
end
