class Groupfeed
  include Mongoid::Document
  include Mongoid::Timestamps
  field :group_id
  referenced_in :feed
  referenced_in :person
  field :statu, :default => 'A'
  key :person_id, :group_id, :feed_id

  validates_presence_of   :person_id, :group_id, :feed_id
  validates_uniqueness_of :person_id, :group_id, :feed_id
end
