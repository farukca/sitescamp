class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Paperclip
  #include Mongoid::Taggable

  field :campuser
  field :name
  field :surname
  field :gender
  field :birthdate, :type => Date
  field :country
  field :language
  field :interest
  field :profile_updated, :type => Boolean, :default => false

  #has_mongoid_attached_file :photo,
  #  :url   => '/assets/posts/:id/:style.:extension',
  #  :path  => ':rails_root/public/posts/sites/:id/:style.:extension',
  #  :styles => { :original => ['1920x1680>', :jpg], :profile => ['195x260', :jpg], :small    => ['50x50',   :jpg] }

  referenced_in :user
  embeds_many :sources
  embeds_many :usergroups
  references_many :groupfeeds
  #references_many :personfeeds, :inverse_of => :people, :class_name => "Personfeed"

  validates_presence_of :campuser#, :name, :surname

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :surname, :gender, :birthdate, :language, :country, :interest

  #def save
  #  self.fullname = (self.name + ' ' + self.surname).strip!
  #  super
  #end

  def add_group(g)
    group = Usergroup.new()
    group.title = g
    self.usergroups << group
    group.save!
    group
  end

  def add_feed_to_follow(feed)
    source = Source.new()
    source.source_type = "F"
    source.source_id   = feed.id
    self.sources << source
    source.save!
  end

  #def person_source_ids
  #  self.sources.all(:source_type => "F").collect(&:source_id)
  #  #target_contacts = Personfeed.all(:aspect_ids.in => target_aspect_ids, :pending => false)
  #  #person_ids = people.map{|x| x.person_id}
  #  #Person.all(:id.in => person_ids)
  #end

  def person_source_ids(sourcetype)
    self.sources.all(:source_type => sourcetype).collect(&:source_id)
  end

  def check_person_source(sourcetype, sourceid)
    #debugger
    src = self.sources.where(:source_type => sourcetype, :source_id => sourceid).collect(&:source_id).to_s
    if src.length<3
      false
    else
      true
    end
  end

  def person_group_ids
    self.usergroups.all.collect(&:_id)
  end

end
