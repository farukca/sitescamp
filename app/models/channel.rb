class Channel
  include Mongoid::Document
  field :name
  field :desc
  field :icon
  referenced_in :category
  references_many :feeds

  validates_presence_of :name
  validates_length_of :name, :minimum => 2, :maximum => 30
end
