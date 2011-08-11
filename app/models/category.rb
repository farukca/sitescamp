class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Taggable

  field :name
  field :desc
  field :icon
  field :score, :type => Integer, :default => 0

  references_many :channels
  references_many :feeds

  validates_presence_of :name
  validates_length_of :name, :minimum => 2, :maximum => 30

  def cat_feed_ids
    self.feeds.all.collect(&:_id)
  end

  def homeposts
    str_ids = self.cat_feed_ids
    unless str_ids.to_s.length < 3 
      Feedpost.recents.postsbyfeeds(str_ids).only(:id,:feed_id,:title,:author,:published).order_by(:published, :desc).limit(8)
    end
  end
end
