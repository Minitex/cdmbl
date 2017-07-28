[![Build Status](https://travis-ci.org/UMNLibraries/cdmbl.svg?branch=master)](https://travis-ci.org/UMNLibraries/cdmbl)

# CDMBL: CONTENTdm on Blacklight

Use [Blacklight](https://github.com/projectblacklight/blacklight) as a front end for your CONTENTdm instance.

At the moment, CDMBL consists only of a micro [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) system dedicated to extracting metadata records from a CONTENTdm instance (using the [CONTENTdm API gem](https://github.com/UMNLibraries/contentdm_api), transforming them into Solr documents, and loading them into Solr.

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

### GeoNames (optional)

In order to make use of the GeoNames service, you must purchase a [GeoNames Premium Webservices Account](http://www.geonames.org/commercial-webservices.html). If you do not have a `geonam` field in your CONTENTdm schema, you may ignore this instruction. Add your credentials to your shell environment once you have secured a GeoNames user:

```
# e.g. within your .bash_profile or .zprofile file
export export GEONAMES_USER="yourusernamehere"
```

## Usage

Run the ingester

rake cdmbl:batch[solr_url,oai_endpoint,cdm_endpoint,set_spec, batch_size, max_compounds]

|Argument| Definition|
|--:|---|
|solr_url| The full URL to your Solr core instance (same as your blacklight.yml solr url)|
|oai_endpoint| A URL to your OAI instance (e.g. https://server16022.contentdm.oclc.org/oai/oai.php)   |
|cdm_endpoint| A URL to your CONTENTdm API endpoint (e.g. https://server16022.contentdm.oclc.org/dmwebservices/index.php) |
|set_spec| Selectively harvest from a single collection with [setSpec](http://www.openarchives.org/OAI/openarchivesprotocol.html#Set)|
|batch_size| The number of records to transform at a time. **Note**: it is within the record transformation process that the CONTENTdm API is requested. This API can be sluggish, so we conservatively transform batches of ten records at a time to prevent timeouts.|
|max_compounds| CONTENTdm records with many compounds can take a long time to load from the CONTENTdm API as multiple requests must happen in order to get the metadata for each child record of a parent compound object. For this reason, records with ten or more compound children are, by default, processed in batches of one. This setting allows you to override this behavior.|

For example:

```ruby
rake "cdmbl:ingest[http://solr:8983/solr/foo-bar-core, https://server16022.contentdm.oclc.org/oai/oai.php, https://server16022.contentdm.oclc.org/dmwebservices/index.php, 2015-01-01]"
```

### Custom Rake Tasks

You might also create your own rake task to run your modified field transformers:

```ruby
require 'cdmbl'

namespace :cdmbl do
  desc "ingest batches of records"
  ##
  # e.g. rake mdl_ingester:ingest[2015-09-14, 2]
  task :batch, [:batch_size, :set_spec] => :environment  do |t, args|
    config  =
      {
        oai_endpoint: 'http://cdm16022.contentdm.oclc.org/oai/oai.php',
        cdm_endpoint: 'https://server16022.contentdm.oclc.org/dmwebservices/index.php',
        set_spec: (args[:set_spec] != '""') ? args[:set_spec] : nil,
        max_compounds: (args[:max_compounds]) ? args[:max_compounds] : 2,
        batch_size: (args[:batch_size]) ? args[:batch_size] : 30,
        solr_config: solr_config
      }
    CDMBL::ETLWorker.perform_async(config)
  end
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
* The [react-borealis viewer](https://github.com/UMNLibraries/react-borealis)
