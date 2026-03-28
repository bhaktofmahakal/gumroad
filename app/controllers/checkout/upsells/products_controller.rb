# frozen_string_literal: true

class Checkout::Upsells::ProductsController < ApplicationController
  include CustomDomainConfig

  def index
    seller = user_by_domain(request.host) || current_seller
    products = seller.products
      .eligible_for_content_upsells
      .includes(:variant_categories, :variants, :skus)
      .to_a

    preload_variant_sales_counts(products)

    render json: products.map { |product| Checkout::Upsells::ProductPresenter.new(product, preloaded_options: true).product_props }
  end

  def show
    product = Link.eligible_for_content_upsells
                  .find_by_external_id!(params[:id])

    render json: Checkout::Upsells::ProductPresenter.new(product).product_props
  end

  private

  def preload_variant_sales_counts(products)
    all_variants = products.flat_map { |p| p.variants.to_a + p.skus.to_a }
    variants_with_limits = all_variants.select(&:max_purchase_count)
    return if variants_with_limits.empty?

    counts = Purchase
      .counts_towards_inventory
      .joins("INNER JOIN base_variants_purchases ON base_variants_purchases.purchase_id = purchases.id")
      .where("base_variants_purchases.base_variant_id": variants_with_limits.map(&:id))
      .group("base_variants_purchases.base_variant_id")
      .sum(:quantity)

    variants_with_limits.each do |variant|
      variant.preloaded_sales_count_for_inventory = counts[variant.id] || 0
    end
  end
end
