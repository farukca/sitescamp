class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :desc
  field :icon

  references_many :channels
  references_many :feeds

  validates_presence_of :name
  validates_length_of :name, :minimum => 2, :maximum => 30
end
