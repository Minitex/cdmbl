$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cdmbl'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'
require 'sidekiq/testing'

# Avoid testing solr itself
module CDMBL

  class TestConnection
    def get(query, params)
      {
        'response' => {
        'docs' => [
          {'id' => 'irrc:1600'},
          {'id' => 'irrc:1601'},
          {'id' => 'irrc:1601'},
          {'id' => 'irrc:1568'},
          {'id' => 'irrc:1569'},
          {'id' => 'irrc:1747'},
          {'id' => 'otter:297'},
          {'id' => 'nemhc:5897'},
          {'id' => 'pch:612'},
          {'id' => 'bad:ID'}
        ],
        'numFound' => 10 }
      }
    end

    def add(records)
    end

    def commit
    end

    def delete_by_id(ids)
    end
  end

  class TestClient
    def self.connect(url)
      TestConnection.new
    end
  end

  class TestSolr < DefaultSolr
    def initialize(url: 'http://localhost:8983', client: TestClient)
      super(url: url, client: client)
    end
  end

  # An example callback
  class Callback
    def self.call!(solr_client)
      'blerg this is a test callback'
    end
  end
end