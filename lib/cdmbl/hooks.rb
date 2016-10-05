module CDMBL
  def self.const_missing(name)
    if name.to_s == 'Solr'
      hook(pattern: name.to_s, default: DefaultSolr)
    elsif name.to_s == 'Callback'
      hook(pattern: name.to_s, default: DefaultCallback)
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