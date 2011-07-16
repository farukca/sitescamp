class Feedpost
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
  field :images, :type => Array
  field :videos, :type => Array
  field :sublinks, :type => Array
  field :realurl
  field :tags, :type => Array

  referenced_in :feed
  references_many :sitefeeds

  default_scope descending(:published)
  #scope :recents, where(published: {'$gte' => Time.now.midnight, '$lt' => Time.now.midnight + 24.hours})
  #scope :recents, where(:published.gte=>Date.today.midnight)
  scope :recents, order_by(:published, :desc)
  scope :with_images, where(:images.exists => true) 

  scope :postsbyfeeds, ->(feedids) { where(:feed_id.in => feedids) }

  after_create :get_from_diffbot

  def analyze_links(link)
    begin
      uri = URI.parse(URI.encode(link))
      strHost = uri.host
      unless strHost.nil?
        if !strHost.index('www.').nil?
           strHost["www."] = ""
        end
        site = Site.find_or_create_by(website: strHost)
        sitefeed = Sitefeed.find_or_initialize_by(site_id: site.id, feedpost_id: self.id)
        #debugger
        if sitefeed.links.nil?
          sitefeed.links = []
        end
        sitefeed.links << link
        sitefeed.save!
      end
    rescue URI::InvalidURIError
#TODO burada hata mesajını bir tabloya kaydedebiliriz, current_user, tarih, hata aldığı model,controller ismi ve method ismi alanlar ile
      puts link
    end
  end
  handle_asynchronously :analyze_links, :priority => 40

  protected
  def get_from_diffbot
    response = Net::HTTP.get(URI.parse("http://www.diffbot.com/api/article?token=72c1f018e28409e24883ef98039da6ab&tags&html&summary&stats&url="+self.url))
    
    #strIcon = JSON.parse(response.to_s)['icon']
    strSummary = JSON.parse(response.to_s)['summary']
    unless strSummary.nil?
        self.summary = AutoExcerpt.new(strSummary, {:strip_html => true, :allowed_tags => %w(p), :characters => 200, :ending => nil})
    end
   
    strTags    = JSON.parse(response.to_s)['tags']
    unless strTags.nil?
      self.tags ||= Array.new
      self.tags << strTags
      #analyze_tags(strTags)
    end

    strURL     = JSON.parse(response.to_s)['resolved_url']
    unless strURL.nil?
      self.realurl  = strURL.sanitize.downcase
    end
    
    strLink    = JSON.parse(response.to_s)['media']
    if not strLink.nil?
      imgArr = Array.new
      vidArr = Array.new
      i = 0;
      while i < strLink.length  do
        if strLink[i]['type'] == 'image'
          imgArr << strLink[i]['link']
        end
        if strLink[i]['type'] == 'video'
          vidArr << strLink[i]['link']
        end
        i +=1;
      end
      if imgArr.length > 0
        self.images = imgArr
      end
      if vidArr.length > 0
        self.videos = vidArr
      end
    end

    strText    = JSON.parse(response.to_s)['html']
    unless strText.nil?

      feedUrl = self.realurl
      if feedUrl.nil? 
        feedUrl = self.url
      end

      if not feedUrl.nil?
        begin
          uri = URI.parse(URI.encode(feedUrl))
          feedSite = uri.host
          feedSite["www."] = ""
        rescue URI::InvalidURIError
          feedSite = ""
        end
      end if

      self.content = strText
      links = []
      strText.scan(/href\s*=\s*\"*[^\">]*/i) do |link|
        link = link.sub(/href="/i, "")

        unless link.nil?
          begin
            uri = URI.parse(URI.encode(link))
            #if feedSite != uri.host
            unless link.include? feedSite.to_s
              self.analyze_links(link)
            end
            links << link
          rescue URI::InvalidURIError
#TODO burada hata mesajını bir tabloya kaydedebiliriz, current_user, tarih, hata aldığı model,controller ismi ve method ismi alanlar ile
            puts link
          end
        end      
      end
      self.sublinks = links
    end
    self.save!     
  end
  handle_asynchronously :get_from_diffbot, :priority => 30

end
