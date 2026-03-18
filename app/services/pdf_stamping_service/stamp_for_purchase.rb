# frozen_string_literal: true

module PdfStampingService::StampForPurchase
  extend self

  def perform!(purchase)
    product = purchase.link
    return unless product.has_stampable_pdfs?

    purchase_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    url_redirect = UrlRedirect.find(purchase.url_redirect.id)
    product_files_to_stamp = find_products_to_stamp(product, url_redirect)

    results = Set.new
    product_files_to_stamp.each do |product_file|
      file_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      results << process_product_file(url_redirect:, product_file:, watermark_text: purchase.email)
      file_duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - file_start
      Rails.logger.info("[PdfStamping] file_id=#{product_file.id} purchase_id=#{purchase.id} duration=#{file_duration.round(2)}s")
    end

    failed_results = results.reject(&:success?)
    purchase_duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - purchase_start

    if failed_results.none?
      url_redirect.update!(is_done_pdf_stamping: true)
      Rails.logger.info("[PdfStamping] purchase_id=#{purchase.id} files=#{product_files_to_stamp.size} total_duration=#{purchase_duration.round(2)}s status=success")
      true
    else
      debug_info = failed_results.map do |result|
        "File #{result.product_file_id}: #{result.error[:class]}: #{result.error[:message]}"
      end.join("\n")
      Rails.logger.info("[PdfStamping] purchase_id=#{purchase.id} files=#{product_files_to_stamp.size} failed=#{failed_results.size} total_duration=#{purchase_duration.round(2)}s status=failure")
      raise PdfStampingService::Error, "Failed to stamp #{failed_results.size} file(s) for purchase #{purchase.id} - #{debug_info}"
    end
  end

  private
    def find_products_to_stamp(product, url_redirect)
      product.product_files
        .alive
        .pdf
        .pdf_stamp_enabled
        .where.not(id: url_redirect.alive_stamped_pdfs.pluck(:product_file_id))
    end

    def process_product_file(url_redirect:, product_file:, watermark_text:)
      stamped_pdf_url = stamp_and_upload!(product_file:, watermark_text:)
      return OpenStruct.new(success?: true) if stamped_pdf_url.nil?
      url_redirect.stamped_pdfs.find_or_create_by!(product_file:) do |stamped_pdf|
        stamped_pdf.url = stamped_pdf_url
      end
      OpenStruct.new(success?: true)
    rescue *PdfStampingService::ERRORS_TO_RESCUE => error
      OpenStruct.new(
        success?: false,
        product_file_id: product_file.id,
        error: {
          class: error.class.name,
          message: error.message
        }
      )
    end

    def stamp_and_upload!(product_file:, watermark_text:)
      return if product_file.cannot_be_stamped?

      stamped_pdf_path = PdfStampingService::Stamp.perform!(product_file:, watermark_text:)
      PdfStampingService::UploadToS3.perform!(product_file:, stamped_pdf_path:)
    ensure
      File.unlink(stamped_pdf_path) if File.exist?(stamped_pdf_path.to_s)
    end
end
