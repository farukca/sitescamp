class Feed
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Paperclip
  include Mongoid::Taggable
  include Mongoid::Mebla
  include ActiveModel::Validations

  field :title
  field :site_url
  field :feed_url
  field :status, :default => 'F'
  field :etag
  field :last_modified, :type => Time
  field :logo
  field :detail

  mount_uploader :logo, AvatarUploader
  #has_mongoid_attached_file :logo,
  #  :url   => '/assets/feeds/:id/:style.:extension',
  #  :path  => ':rails_root/public/assets/feeds/:id/:style.:extension',
  #  :styles => { :small    => ['50x50', :jpg] }

  references_many :feedposts
  references_many :groupfeeds
  referenced_in :category
  #referenced_in :channel
  
  index :title
  search_in :title #=> { :boost => 2.0, :analyzer => 'titlelyzer' }
  
  attr_accessible :title, :site_url, :feed_url, :logo, :remote_logo_url, :category_id, :detail

  validates_presence_of   :feed_url
  validates_uniqueness_of :feed_url, :case_sensitive => false
  validates_url :feed_url
  validates_url :site_url, :allow_blank => true

  #validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/jpg', 'image/png']

  def get_entries(source_feed)
    updated_feed = Feedzirra::Feed.fetch_and_parse(source_feed.feed_url)
    #updated_feed.sanitize_entries!
    #debugger
    unless updated_feed.nil?
      unless updated_feed.entries.nil?
        updated_feed.entries.each do |entry|
          create_new_entry(entry, source_feed)
        end

        source_feed.title     = updated_feed.title
        source_feed.site_url  = updated_feed.url
        source_feed.etag      = updated_feed.etag
        source_feed.last_modified = updated_feed.last_modified
        source_feed.status    = "A"
        source_feed.save!
      end
    end
  end
  handle_asynchronously :get_entries, :priority => 10

  def create_new_entry(e, f)
    #for readwriteweb, content is coming null from readwriteweb
    #if e.content.to_s.blank?
    #   e.content = e.summary.sanitize
    #end
    #fpost = Feedpost.where(feed_id: f.id, entry_id: e.entry_id)
    unless Feedpost.exists?(:conditions => {:feed_id => f.id, :entry_id => e.entry_id})
      Feedpost.create!(
        :title  => e.title.sanitize,
        :url    => e.url.sanitize,
        :author => e.author,
    #    :summary => e.summary.sanitize,
    #    :content => e.content,
        :published => e.published,
        :categories => e.categories,
        :entry_id => e.entry_id,
        :feed_id  => f.id
      )
    end
  end

  def get_new_entries(source_feed)

    feed_to_update = Feedzirra::Parser::Atom.new
    feed_to_update.feed_url = source_feed.feed_url
    feed_to_update.etag = source_feed.etag
    feed_to_update.last_modified = source_feed.last_modified

    #last_entry = Feedzirra::Parser::AtomEntry.new
    #last_entry.url = the_url_of_the_last_entry_for_a_feed
    #feed_to_update.entries = [last_entry]

    updated_feed = Feedzirra::Feed.update(feed_to_update)

    #updated_feed.updated? # => nil if there is nothing new
    #updated_feed.new_entries # => [] if nothing new otherwise a collection of feedzirra entries
    #updated_feed.etag # => same as before if nothing new. although could change with comments added to entries.
    #updated_feed.last_modified # => same as before if nothing new. although could change with comments added to entries.

    #f = Feedzirra::Feed.update(self)
    #if f.updated?
    unless updated_feed.nil?
      if not updated_feed.new_entries.blank?
        #updated_feed.sanitize_entries!
        updated_feed.new_entries.each do |entry|
          create_new_entry(entry, source_feed)
        end       
      end
      source_feed.etag = updated_feed.etag
      source_feed.last_modified = updated_feed.last_modified
      source_feed.save!
    end
  end
  handle_asynchronously :get_new_entries, :priority => 20

  def set_icon_from_diffbot(icon_url)
    #debugger
    if self.logo.to_s.blank?
      self.remote_logo_url = icon_url
      self.save!
    end
  end
  #handle_asynchronously :set_icon_from_diffbot, :priority => 50

  def self.select_to_update
    feeds = Feed.where(:status => 'A')
    feeds.each do |feed|
      feed.get_new_entries(feed)
    end
  end

  def todaycount
    return Feedpost.count(conditions: {:published.gte => Time.now.midnight, :feed_id => self.id})
  end

  def yesterdaycount
    return Feedpost.count(conditions: {:published.gte => Time.now.midnight-1.day, :published.lt => Time.now.midnight, :feed_id => self.id})
  end

end
