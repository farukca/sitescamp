class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Paperclip
  #include Mongoid::Taggable

  field :content
  field :post_type
  field :remote_url
  #has_mongoid_attached_file :photo,
  #  :url   => '/assets/posts/:id/:style.:extension',
  #  :path  => ':rails_root/public/posts/sites/:id/:style.:extension',
  #  :styles => { :original => ['1920x1680>', :jpg], :small    => ['150x150#',   :jpg] }
  #has_attached_file :video,
  #  :url   => '/assets/posts/:id/:style.:extension',
  #  :path  => ':rails_root/public/posts/sites/:id/:style.:extension'

  referenced_in :site
  referenced_in :user
  validates_presence_of :user, :site, :content

end
