#require 'public/uploads/userfiles'
#require 'carrierwave/orm/mongoid'
class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Paperclip
  include Mongoid::Taggable

  field :website
  field :name
  field :detail
  field :email
  field :phone
  field :logo
  field :category
  field :sitetype
  field :found_date, :type => Date
  field :blog
  field :feed_url
  field :twitter

  mount_uploader :logo, AvatarUploader

  #has_mongoid_attached_file :logo,
  #  :url   => '/assets/sites/:id/:style.:extension',
  #  :path  => ':rails_root/public/assets/sites/:id/:style.:extension',
  #  :styles => {
  #    :original => ['1920x1680>', :jpg],
  #    :small    => ['100x100#',   :jpg],
  #    :medium   => ['195x260',    :jpg],
  #    :large    => ['500x500>',   :jpg]
  #  }

  references_many :posts
  references_many :sitefeeds

  disable_tags_index!
  tags_separator ','


  validates_presence_of :website
  validates_exclusion_of :sitetype, :in => ["A","P"]
  validates_exclusion_of :category, :in => ["A","B","C"]
  validates_length_of :website, :minimum => 5, :maximum => 50

  #validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/jpg', 'image/png']

  #attr_accessible :website

  before_create :get_site_name

  def get_site_name
    if !self.website.blank?
      if !self.website.index('http://').nil?
         self.website["http://"] = ""
      end
      if !self.website.index('www.').nil?
         self.website["www."] = ""
      end
      #opts[:website].gsub!("http://","").gsub!("www.","").sub!(/\/.*$/, "")
      #opts[:website].sub!(/\/.*$/, "")  
      self.name = self.website.sub(/.com.*$/, "")
      self.name.capitalize!
      #self.email = "@" << opts[:website]
    end
  end

end
