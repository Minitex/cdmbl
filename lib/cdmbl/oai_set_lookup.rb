# require 'active_support/core_ext/hash/conversions'
# require 'hash_at_path'

# module CDMBL
#   # Takes a hash representing an OAI ListSets response and turns that into a
#   # lookup table based on the setSpec
#   class OAISetLookup
#     attr_reader :oai_sets
#     def initialize(oai_sets: {})
#       @oai_sets = oai_sets
#     end

#     def keyed
#       oai_sets.at_path('OAI_PMH/ListSets/set').inject({}) {|memo, set| memo.merge(to_key(set)) }
#     end

#     private

#     def to_key(set)
#       {set['setSpec'] => {name: set['setName'], description: set.at_path('setDescription/dc/description')}}
#     end
#   end
# end