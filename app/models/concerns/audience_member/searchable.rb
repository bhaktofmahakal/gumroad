# frozen_string_literal: true

module AudienceMember::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include SearchIndexModelCommon
    include ElasticsearchModelAsyncCallbacks

    index_name "audience_members"

    settings number_of_shards: 1, number_of_replicas: 0

    mapping dynamic: :strict do
      indexes :id,                        type: :long
      indexes :seller_id,                 type: :long
      indexes :email,                     type: :keyword
      indexes :customer,                  type: :boolean
      indexes :follower,                  type: :boolean
      indexes :affiliate,                 type: :boolean
      indexes :min_paid_cents,            type: :long
      indexes :max_paid_cents,            type: :long
      indexes :min_created_at,            type: :date
      indexes :max_created_at,            type: :date
      indexes :min_purchase_created_at,   type: :date
      indexes :max_purchase_created_at,   type: :date
      indexes :follower_id,               type: :long
      indexes :follower_created_at,       type: :date
      indexes :min_affiliate_created_at,  type: :date
      indexes :max_affiliate_created_at,  type: :date
      indexes :purchases, type: :nested do
        indexes :id,          type: :long
        indexes :product_id,  type: :long
        indexes :variant_ids, type: :long
        indexes :price_cents, type: :long
        indexes :created_at,  type: :date
        indexes :country,     type: :keyword
      end
      indexes :affiliates, type: :nested do
        indexes :id,          type: :long
        indexes :product_id,  type: :long
        indexes :created_at,  type: :date
      end
    end

    ATTRIBUTE_TO_SEARCH_FIELDS = {
      "email" => "email",
      "details" => %w[purchases affiliates follower_id follower_created_at],
      "customer" => "customer",
      "follower" => "follower",
      "affiliate" => "affiliate",
      "min_paid_cents" => "min_paid_cents",
      "max_paid_cents" => "max_paid_cents",
      "min_created_at" => "min_created_at",
      "max_created_at" => "max_created_at",
      "min_purchase_created_at" => "min_purchase_created_at",
      "max_purchase_created_at" => "max_purchase_created_at",
      "follower_created_at" => "follower_created_at",
      "min_affiliate_created_at" => "min_affiliate_created_at",
      "max_affiliate_created_at" => "max_affiliate_created_at",
      "seller_id" => "seller_id",
    }

    def search_field_value(field_name)
      case field_name
      when "id", "seller_id", "email", "customer", "follower", "affiliate",
           "min_paid_cents", "max_paid_cents",
           "min_created_at", "max_created_at",
           "min_purchase_created_at", "max_purchase_created_at",
           "follower_created_at",
           "min_affiliate_created_at", "max_affiliate_created_at"
        attributes[field_name]
      when "follower_id"
        details.dig("follower", "id")
      when "purchases"
        Array.wrap(details["purchases"]).map do |p|
          {
            id: p["id"],
            product_id: p["product_id"],
            variant_ids: Array.wrap(p["variant_ids"]),
            price_cents: p["price_cents"],
            created_at: p["created_at"],
            country: p["country"],
          }
        end
      when "affiliates"
        Array.wrap(details["affiliates"]).map do |a|
          {
            id: a["id"],
            product_id: a["product_id"],
            created_at: a["created_at"],
          }
        end
      end.as_json
    end
  end

  class_methods do
    # Build an ES query hash equivalent to AudienceMember.filter() for counting.
    def es_filter_query(seller_id:, params: {})
      params = params.slice(
        :type,
        :bought_product_ids, :bought_variant_ids,
        :not_bought_product_ids, :not_bought_variant_ids,
        :paid_more_than_cents, :paid_less_than_cents,
        :created_after, :created_before,
        :bought_from,
        :affiliate_product_ids
      ).compact_blank

      filters = [{ term: { seller_id: seller_id } }]
      must_nots = []

      # Type filter
      filters << { term: { params[:type].to_sym => true } } if params[:type]

      # Price range filters (on denormalized columns — fast pre-filter)
      filters << { range: { max_paid_cents: { gt: params[:paid_more_than_cents] } } } if params[:paid_more_than_cents]
      filters << { range: { min_paid_cents: { lt: params[:paid_less_than_cents] } } } if params[:paid_less_than_cents]

      # Date range filters (on denormalized columns)
      if params[:created_after] || params[:created_before]
        min_col, max_col =
          case params[:type]
          when "customer" then [:min_purchase_created_at, :max_purchase_created_at]
          when "follower" then [:follower_created_at, :follower_created_at]
          when "affiliate" then [:min_affiliate_created_at, :max_affiliate_created_at]
          else [:min_created_at, :max_created_at]
          end

        filters << { range: { max_col => { gt: params[:created_after] } } } if params[:created_after]
        filters << { range: { min_col => { lt: params[:created_before] } } } if params[:created_before]
      end

      # Determine if we need correlated (nested) purchase filtering.
      # This mirrors the MySQL JSON_TABLE logic: when combining product/variant selection
      # with price/date/country, conditions must match within the same purchase row.
      needs_correlated = (params[:bought_product_ids] || params[:bought_variant_ids]) &&
        (params[:paid_more_than_cents] || params[:paid_less_than_cents] || params[:created_after] || params[:created_before] || params[:bought_from])
      needs_correlated ||= (params[:paid_more_than_cents] && params[:paid_less_than_cents])
      needs_correlated ||= (params[:created_after] && params[:created_before])

      if needs_correlated
        # Single nested query that correlates all purchase-level conditions
        nested_filters = []
        nested_shoulds = []

        if params[:bought_product_ids] && params[:bought_variant_ids]
          nested_shoulds << { terms: { "purchases.product_id" => params[:bought_product_ids] } }
          nested_shoulds << { terms: { "purchases.variant_ids" => params[:bought_variant_ids] } }
        elsif params[:bought_product_ids]
          nested_filters << { terms: { "purchases.product_id" => params[:bought_product_ids] } }
        elsif params[:bought_variant_ids]
          nested_filters << { terms: { "purchases.variant_ids" => params[:bought_variant_ids] } }
        end

        nested_filters << { range: { "purchases.price_cents" => { gt: params[:paid_more_than_cents] } } } if params[:paid_more_than_cents]
        nested_filters << { range: { "purchases.price_cents" => { lt: params[:paid_less_than_cents] } } } if params[:paid_less_than_cents]
        nested_filters << { range: { "purchases.created_at" => { gt: params[:created_after] } } } if params[:created_after]
        nested_filters << { range: { "purchases.created_at" => { lt: params[:created_before] } } } if params[:created_before]
        nested_filters << { term: { "purchases.country" => params[:bought_from] } } if params[:bought_from]

        nested_bool = {}
        nested_bool[:filter] = nested_filters if nested_filters.present?
        nested_bool[:should] = nested_shoulds if nested_shoulds.present?
        nested_bool[:minimum_should_match] = 1 if nested_shoulds.present?

        filters << {
          nested: {
            path: "purchases",
            query: { bool: nested_bool }
          }
        }
      else
        # Non-correlated: separate nested queries for each condition
        if params[:bought_product_ids] || params[:bought_variant_ids]
          nested_bool = { should: [], minimum_should_match: 1 }
          if params[:bought_product_ids]
            nested_bool[:should] << { terms: { "purchases.product_id" => params[:bought_product_ids] } }
          end
          if params[:bought_variant_ids]
            nested_bool[:should] << { terms: { "purchases.variant_ids" => params[:bought_variant_ids] } }
          end

          filters << {
            nested: {
              path: "purchases",
              query: { bool: nested_bool }
            }
          }
        end

        if params[:bought_from]
          filters << {
            nested: {
              path: "purchases",
              query: { term: { "purchases.country" => params[:bought_from] } }
            }
          }
        end
      end

      # Not-bought filters (must_not with nested)
      if params[:not_bought_product_ids]
        params[:not_bought_product_ids].each do |product_id|
          must_nots << {
            nested: {
              path: "purchases",
              query: { term: { "purchases.product_id" => product_id } }
            }
          }
        end
      end

      if params[:not_bought_variant_ids]
        params[:not_bought_variant_ids].each do |variant_id|
          must_nots << {
            nested: {
              path: "purchases",
              query: { term: { "purchases.variant_ids" => variant_id } }
            }
          }
        end
      end

      # Affiliate product filter
      if params[:affiliate_product_ids]
        filters << {
          nested: {
            path: "affiliates",
            query: { terms: { "affiliates.product_id" => params[:affiliate_product_ids] } }
          }
        }
      end

      bool_query = { filter: filters }
      bool_query[:must_not] = must_nots if must_nots.present?

      { query: { bool: bool_query } }
    end

    # Count audience members using ES. Drop-in replacement for .filter(...).count
    def es_count(seller_id:, params: {})
      query = es_filter_query(seller_id: seller_id, params: params)
      query[:size] = 0
      result = EsClient.search(index: index_name, body: query)
      result.dig("hits", "total", "value")
    end

    # Fetch audience members with IDs from ES.
    # Returns an array of hashes with keys matching what the jobs expect.
    def es_filter_with_ids(seller_id:, params: {})
      query = es_filter_query(seller_id: seller_id, params: params)
      query[:size] = 10_000
      query[:_source] = %w[id email follower_id follower_created_at purchases affiliates]

      results = []
      response = EsClient.search(index: index_name, body: query, scroll: "2m")

      loop do
        hits = response.dig("hits", "hits")
        break if hits.blank?

        hits.each do |hit|
          results << build_member_from_es_hit(hit["_source"], params)
        end

        break if hits.size < 10_000
        response = EsClient.scroll(body: { scroll_id: response["_scroll_id"] }, scroll: "2m")
      end

      EsClient.clear_scroll(body: { scroll_id: response["_scroll_id"] }) if response["_scroll_id"]
      results
    end

    private
      def build_member_from_es_hit(source, params)
        purchases = Array.wrap(source["purchases"])
        affiliates = Array.wrap(source["affiliates"])

        # Pick the most relevant purchase_id (max id, matching MySQL GROUP BY + max() behavior)
        purchase_id = nil
        if purchases.present?
          matching = purchases
          if params[:bought_product_ids] || params[:bought_variant_ids]
            filtered = purchases.select do |p|
              (params[:bought_product_ids]&.include?(p["product_id"])) ||
                (params[:bought_variant_ids] && (Array.wrap(p["variant_ids"]) & params[:bought_variant_ids]).present?)
            end
            matching = filtered if filtered.present?
          end
          purchase_id = matching.max_by { |p| p["id"].to_i }&.dig("id")
        end

        # Pick the most relevant affiliate_id (max id)
        affiliate_id = nil
        if affiliates.present?
          matching = affiliates
          if params[:affiliate_product_ids]
            filtered = affiliates.select { |a| params[:affiliate_product_ids].include?(a["product_id"]) }
            matching = filtered if filtered.present?
          end
          affiliate_id = matching.max_by { |a| a["id"].to_i }&.dig("id")
        end

        {
          id: source["id"],
          email: source["email"],
          purchase_id: purchase_id,
          follower_id: source["follower_id"],
          affiliate_id: affiliate_id,
          details: {
            "purchases" => purchases.presence,
            "follower" => source["follower_id"] ? { "id" => source["follower_id"], "created_at" => source["follower_created_at"] } : nil,
            "affiliates" => affiliates.presence,
          }.compact_blank,
        }
      end
  end
end
