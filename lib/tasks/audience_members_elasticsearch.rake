# frozen_string_literal: true

namespace :audience_members do
  namespace :elasticsearch do
    desc "Create the audience_members ES index"
    task create_index: :environment do
      index_name = AudienceMember.index_name
      if EsClient.indices.exists?(index: index_name)
        puts "Index '#{index_name}' already exists. Delete it first if you want to recreate."
      else
        AudienceMember.__elasticsearch__.create_index!
        puts "Created index '#{index_name}'."
      end
    end

    desc "Delete the audience_members ES index"
    task delete_index: :environment do
      index_name = AudienceMember.index_name
      if EsClient.indices.exists?(index: index_name)
        EsClient.indices.delete(index: index_name)
        puts "Deleted index '#{index_name}'."
      else
        puts "Index '#{index_name}' does not exist."
      end
    end

    desc "Backfill audience_members into ES (batch_size=1000, start_id=0)"
    task backfill: :environment do
      batch_size = (ENV["BATCH_SIZE"] || 1000).to_i
      start_id = (ENV["START_ID"] || 0).to_i
      total = 0

      AudienceMember.where("id > ?", start_id).find_in_batches(batch_size: batch_size) do |batch|
        body = batch.flat_map do |record|
          [
            { index: { _index: AudienceMember.index_name, _id: record.id } },
            record.as_indexed_json
          ]
        end

        EsClient.bulk(body: body) if body.present?
        total += batch.size
        puts "Indexed #{total} audience_members (last id: #{batch.last.id})" if total % 10_000 == 0 || batch.size < batch_size
      end

      puts "Backfill complete. Total indexed: #{total}"
    end
  end
end
