require 'cdmbl'

namespace :cdmbl do
  desc 'Extract OAI results to the local file system.'
  task :extract, [:oai_endpoint, :storage_dir] do |t, args|
    CDMBL::OAIWorker.perform_async(oai_endpoint, false, storage_dir)
  end
end

