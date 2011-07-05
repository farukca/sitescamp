class Sitefeed
  include Mongoid::Document
  referenced_in :site
  referenced_in :feedpost
  field :links, :type => Array
end
