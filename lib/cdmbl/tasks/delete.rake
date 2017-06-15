require 'cdmbl'

namespace :cdmbl do
  desc "delete all records that aren't in a given OAI endpoint"
  task :delete_batch, [:start, :prefix, :oai_url, :solr_url] do |t, args|
        CDMBL::BatchDeleterWorker.perform_async(args[:start].to_i,
                                         args[:prefix],
                                         args[:oai_url],
                                         args[:solr_url])
  end
end

