class Channel
  include Mongoid::Document
  field :name
  field :desc
  field :icon
  referenced_in :category
  field :feeds, :type => Array

  validates_presence_of :name
  validates_length_of :name, :minimum => 2, :maximum => 30

  def add_feed_to_channel(feed)
    if not (self.feeds.index(feed))     
      self.feeds << feed
      self.save!
    end
  end

end
