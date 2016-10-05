[![Build Status](https://travis-ci.org/UMNLibraries/cdmbl.svg?branch=master)](https://travis-ci.org/UMNLibraries/cdmbl)

# CDMBL: CONTENTdm on Blacklight

Use [Blacklight](https://github.com/projectblacklight/blacklight) as a front end for your CONTENTdm instance.

At the moment, CDMBL consists only of a micro [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) system dedicated to extracting metadata records from a CONTENTdm instance (using the [CONTENTdm API gem](https://github.com/UMNLibraries/contentdm_api), transforming them into Solr documents, and loading them into Solr. After initially populating the entire index, CDMBL allows for selective harvesting for incremental Solr index updates.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cdmbl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cdmbl

Add the CDMBL rake task to your project Rakefile:

```ruby
require 'cdmbl/rake_task'
```

## Usage

Run the ingester

rake cdmbl:ingest[solr_url,oai_endpoint,cdm_endpoint,minimum_date]

|Argument| Definition|
|--:|---|
|solr_url| The full URL to your Solr core instance (same as your blacklight.yml solr url)|
|oai_endpoint| A URL to your OAI instance (e.g. http://reflections.mndigital.org/oai/oai.php)   |
|cdm_endpoint| A URL to your CONTENTdm API endpoint (e.g. https://server16022.contentdm.oclc.org/dmwebservices/index.php) |
|minimum_date| Date from which to [selectively harvest](https://www.openarchives.org/OAI/openarchivesprotocol.html#SelectiveHarvesting) identifiers from the OAI endpoint. These identifiers are used to determine which records to delete from your index and which records to request from the CONTENTdm API|

For example:

```ruby
rake "cdmbl:ingest[http://solr:8983/solr/foo-bar-core, http://reflections.mndigital.org/oai/oai.php, https://server16022.contentdm.oclc.org/dmwebservices/index.php, 2015-01-01]"
```

### Custom Rake Task

You might also create your own rake task to run your modified field transformers:

```ruby
require 'cdmbl'

namespace :cdmbl do
  desc 'Launch a background job to index metadata from CONTENTdm int Solr.'
  task :ingest do
    solr_config = { url: 'http://solr:8983/solr/foo-bar-core' }
    etl_config  = { oai_endpoint: 'http://reflections.mndigital.org/oai/oai.php',
                    cdm_endpoint: 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
                    field_mappings: my_field_mappings,
                    minimum_date:  '2016-09-01'}
    CDMBL::ETLWorker.perform_async(solr_config, etl_config)
end
```
### Your Own Custom Solr Field Mappings (see above code snippet)

The default CONTENTdm to Solr field transformation rules may be overriden by calling the CDMBL::ETLWorker (a [Sidekiq worker](https://github.com/mperham/sidekiq)) directly. These rules may be found in the default_mappings method of the [CDMBL::Transformer Class](https://github.com/UMNLibraries/cdmbl/blob/master/lib/cdmbl/transformer.rb).

The transformer expects mappings in the following format:

```ruby
def your_custom_field_mappings
  [
    {dest_path: 'title_tei', origin_path: 'title', formatters: [StripFormatter]},
  ]
end
```
|Argument| Definition|
|--:|---|
|dest_path| The 'destination path' is the name of the field you will be sending to Solr for this field mapping. |
|origin_path| Where to get the field data from the original record for this mapping. |
|formatters| [Formatters](https://github.com/UMNLibraries/cdmbl/blob/master/lib/cdmbl/formatters.rb) perform tasks such as stripping white space or splitting CONTENTdm multi-valued fields (delimited by semicolons) into JSON arrays. |

**Note:** The first formatter receives the value found at the declared `origin_path`. Each formatter declared after the initial formatter will receive a value produced by the preceding formatter. 

Formatters are very simple stateless classes that take a value, do something to it, and respond with a modified version of this value via a class method called `format`. Examples of other formatters may be found in the [Formatters file](https://github.com/UMNLibraries/cdmbl/blob/master/lib/cdmbl/formatters.rb). For Example:

```ruby
  class SplitFormatter
    def self.format(value)
      (value.respond_to?(:split)) ? value.split(';') : value
    end
  end
```

You might also want to simply override some of the default mappings or add your own:

```ruby
mappings = CDMBL::Transformer.default_mappings.merge(your_custom_field_mappings)
```
## A Custom Post-indexing Callback

If you would like to perform some action (e.g. send an email) following the completion of the CDMBL indexing process, you may declare your own callback hook (anything with "Callback" in the class name declared within the CDMBL module space will be used). To do so in Rails, create a Rails initializer file `config/initializers/cdmbl.rb`: 

```ruby
module CDMBL
  class Callback
    def self.call!
      Rails.logger.info("My Custom CDMBL Callback")      
    end
  end
end
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/UMNLibraries/cdmbl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

[MIT](/LICENSE.txt)

## Roadmap

CDMBL could be expanded to include some features from the [MDL](https://github.com/UMNLibraries/mdl_search) project (and be converted intoto a Rails Engine):

* Asyncronous thumbnail caching (e.g. https://github.com/UMNLibraries/mdl_search/blob/master/app/controllers/catalog_controller.rb#L34)
* A (very simple) model to keep track of indexing runs (used like this: https://github.com/UMNLibraries/mdl_search/blob/master/lib/tasks/ingester.rake#L6)
* A template to over-write the standard BL catalog controller to make use of the CDM solr fields?
