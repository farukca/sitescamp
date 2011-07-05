class Usergroup
  include Mongoid::Document
  field :title
  key :title
  embedded_in :person, :inverse_of => :usergroups
end
