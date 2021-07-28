module CDMBL
  def self.const_missing(name)
    case name.to_s
    when 'Solr'
      hook(pattern: name.to_s, default: DefaultSolr)
    when 'CompletedCallback', 'BatchDeleteJobCompletedCallback', 'BatchDeletedCallback'
      hook(pattern: name.to_s, default: DefaultCompletedCallback)
    when 'OaiNotification'
      hook(pattern: name.to_s, default: DefaultOaiNotification)
    when 'LoaderNotification'
      hook(pattern: name.to_s, default: DefaultLoaderNotification)
    when 'CdmNotification'
      hook(pattern: name.to_s, default: DefaultCdmNotification)
    end
  end

  def self.hook(pattern: '', default: false)
    if find_hook(pattern, default)
      Object.const_get("CDMBL::#{find_hook(pattern, default)}")
    else
      default
    end
  end

  def self.find_hook(pattern, default)
    CDMBL.constants.find do |konst|
      if Object.const_get("CDMBL::#{konst}") != default
        /#{pattern}/ =~ konst.to_s
      end
    end
  end
end
