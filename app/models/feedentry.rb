class Feedentry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :url
  field :author
  field :summary
  field :content
  field :published, :type => Time
  field :categories
  field :entry_id

  referenced_in :feed
  index(
    [
      [ :feed_id, Mongo::ASCENDING ],
      [ :entry_id, Mongo::ASCENDING ]
    ],
    :unique => true
  )


end
