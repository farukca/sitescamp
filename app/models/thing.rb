class Thing
  include Mongoid::Document
  field :campuser, :type => String
  field :name, :type => String
  field :model, :type => String
end
