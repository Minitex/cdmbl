require 'titleize'
require 'json'
require 'net/http'
# A handful of very simple formatters to clean up CONTENTdm API metadata
module CDMBL


  class GeoNameID
    def self.format(value)
      value.split('/').last
    end
  end

  class GeoNameIDToJson
    URL = "http://ws.geonames.net/getJSON?username=#{ENV['GEONAMES_USER']}&token=#{ENV['GEONAMES_TOKEN']}"
    def self.format(value)
      JSON.parse(Net::HTTP.get_response(URI.parse("#{URL}&geonameId=#{value}")).body)
    end
  end

  class GeoNameToLocation
    def self.format(value)
      return if !value.respond_to?(:fetch)
      return if !value['lat'] || !value['lng']
      "#{value['lat']},#{value['lng']}"
    end
  end

  class GeoNameToPlaceName
    def self.format(value)
      return if !value.respond_to?(:fetch)
      [
        value['name'],
        value['adminName1'],
        value['adminName2']
      ].select { |place| place != 'Minnesota'}.compact.uniq
    end
  end

  class DefaultFormatter
    def self.format(value)
      value
    end
  end

  class KeywordFormatter
    def self.format(value)
      vals = []
      vals << value['genera'].split(';') if value['genera'].respond_to?(:split)
      vals << value['specif'].split(';') if value['specif'].respond_to?(:split)
      vals << value['subjec'].split(';') if value['subjec'].respond_to?(:split)
      vals.flatten.uniq.sort
    end
  end

  class UniqueFormatter
    def self.format(value)
      if value.respond_to?(:uniq)
        value.uniq
      else
        value.titleize
      end
    end
  end

  class IDFormatter
    def self.format(value)
      value.split('/').join(':')
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
      return '' if values.nil?
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

  class JoinFormatter
    def self.format(value)
      (value.respond_to?(:join)) ? value.join('; ') : value
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