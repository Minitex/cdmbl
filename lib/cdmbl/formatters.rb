require 'titleize'
# A handful of very simple formatters to clean up CONTENTdm API metadata
module CDMBL

  class DefaultFormatter
    def self.format(value)
      value
    end
  end
  
  class Titlieze
    def self.format(value)
      if value.respond_to?(:map)
        value.map {|value| value.titleize }
      else
        value.titleize
      end
    end
  end

  class ImageId
    def self.format(value)
      value
    end
  end

  class ToJsonFormatter
    def self.format(values)
      values.to_json if values.respond_to?(:to_json)
    end
  end

  class StripSemicolonFormatter
    def self.format(values)
      if values.respond_to?(:map)
        values.map {|value| value.gsub(/;/, '') }
      else
        values.gsub(/;/, '')
      end
    end
  end

  class StripFormatter
    def self.format(values)
      if values.respond_to?(:map)
        values.map {|value| value.strip }
      else
        values.strip
      end
    end
  end

  class SplitFormatter
    def self.format(value)
      (value.respond_to?(:split)) ? value.split(';') : value
    end
  end

  class AddSetSpecFormatter
    def self.format(value)
      value.merge('setSpec' => value['id'].split('/').first)
    end
  end

  class SetSpecFormatter
    def self.format(value)
      value['setSpec']
    end
  end

  class CollectionNameFormatter
    def self.format(value)
      value['oai_sets'].fetch(value['setSpec'], {})
                       .fetch(:name, '')
    end
  end

  class CollectionDescriptionFormatter
    def self.format(value)
      value['oai_sets'].fetch(value['setSpec'], {})
                       .fetch(:description, '')
    end
  end

  class FilterBadCollections
    def self.format(value)
      (/Collection information undefined/i =~ value) ? '' : value
    end
  end

  class ToIFormatter
    def self.format(value)
      value.to_i if value.respond_to?(:to_i)
    end
  end

  class LocationFormatter
    def self.format(record)
      if record['latitu'] && record['longit'] && record['latitu'] != '' && record['longit'] != '' && record['latitu'] != {}
        "#{record['latitu']}, #{record['longit']}"
      else
        nil
      end
    end
  end

end