class FeedsController < ApplicationController

  before_filter :authenticate_user!, :only => [:follow]

  respond_to :html, :js

  def index
    #@feeds = Feed.find(:all).paginate(:all, :per_page => 5, :page => params[:page])
    @feeds = Feed.find(:all)
  end

  def show
    @feed = Feed.find(params[:id])
    @feedposts = Feedpost.where(:feed_id => @feed.id).descending(:published).page params[:page]
    @relatedfeeds = Feed.not_in(_id: [@feed.id]).limit(4)
    respond_with @feed
  end  

  def create
    @feed = Feed.find(:first, :conditions => {:feed_url => params[:feed][:feed_url]})

    if @feed.nil?
      unless check_url(params[:feed][:feed_url])
        raise SitescampException::InvalidUrl
      end
      @feed = Feed.create!(params[:feed])
      @feed.get_entries(@feed)
    end

    if current_user
      @person = current_user.person

      if not @person.check_person_source("F", @feed.id)
        @person.add_feed_to_follow(@feed)
      end
    end
    #update_from_feed(@feed.feed_url)
    
    respond_with @feed, :notice => "New source has been created"
  end 

  def new
    @feed = Feed.new
    respond_with(@feed)
  end

  def edit
    @feed = Feed.find(params[:id])
  end

  def update
    @feed = Feed.find(params[:id])
    #@feed.write_attribute(:logo, params[:feed][:logo])

    @feed.logo = params[:feed][:logo] if not params[:feed][:logo].nil?
    if @feed.update_attributes(params[:feed])
      respond_with(@feed, :notice => 'Feed updated successfully .')
    else
      render :action => "edit"
    end
  end

  def getnews
    @feed = Feed.find(params[:id])

    if not @feed.nil?
      @feed.get_entries(@feed)
    end
    respond_with @feed, :location => root_url, :notice => "Feed added to resources"
  end

  def groupfeeds
    @person = current_user.person
    str_ids = Groupfeed.find(:all, :conditions => {:group_id => params[:group_id], :person_id => @person.id}).collect(&:feed_id) 
    #@feeds  = Feed.any_in(:id => str_ids).ascending(:title)
    @feeds = Feed.find(:all)
    respond_with @feeds
  end

  def tipinfo
    @feed = Feed.find(params[:id])
  end

  def follow
    @person  = current_user.person
    group = params[:group_id]
    @feed = Feed.find(params[:id])
    unless @feed.nil?
      if not group.to_s.blank?
        @grpfeed = Groupfeed.create!(
          :group_id  => group,
          :person_id => @person.id,
          :feed_id   => @feed.id
        )
      end

      @person.add_feed_to_follow(@feed)
    end
    respond_with @feed, :notice => @feed.title+" added to sources"
  end

  
  def check_url (url)
    regexp =/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
    if not regexp.match(url)
       return false 
    end
    return true 
  end

end
