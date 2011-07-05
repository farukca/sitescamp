class Source
  include Mongoid::Document
  #include Mongoid::Taggable
  field :source_type
  field :source_id
  field :group_id
  embedded_in :person, :inverse_of => :sources
end
