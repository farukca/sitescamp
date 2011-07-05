class SitesController < ApplicationController

  #before_filter :authenticate_user!, :except => [:search, :show, :index]

  respond_to :html, :js

  # GET /sites
  # GET /sites.xml
  def index
    @sites = Site.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  def search
    @site = Site.find(:first, :conditions => {:website => params[:website]})

    respond_to do |format|
      if @site.nil?
        @site = Site.new
        @site.get_site_name(params)
        @site.website = params[:website]
        format.html { render :action => "new" }
      else
         format.html { redirect_to @site }
      end
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id])
    strFeedIds = @site.sitefeeds.collect(&:feedpost_id)
    #debugger
    @feedposts = Feedpost.where(:_id.in => strFeedIds).descending(:published).page params[:page]
    @relatedsites = Site.not_in(_id: [@site.id]).limit(3)

    #@posts = Post.where(:site_id => params[:id]).order_by(:created_at.desc).paginate(:per_page => 8, :page => params[:page])
    #@posts = get_site_posts(params[:id]).order_by([:user_id, :desc]).paginate(:per_page => 8, :page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new
    respond_with @site
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.xml
  def create
    @site = Site.new(params[:site])
    @site.logo = params[:logo]

    if not @site.id.nil? and not @site.feed_url.nil?
      @feed = Feed.create!(:feed_url => @site.feed_url, :logo => @site.logo, :title => @site.title)
      @person = current_user.person
      if not @person.check_person_source("F", @feed.id)
        @person.add_feed_to_follow(@feed)
      end
    end    
    respond_with @site, :notice => "Site has been saved."
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find(params[:id])
    @site.logo = params[:logo]

    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to(@site, :notice => 'Site was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(sites_url) }
      format.xml  { head :ok }
    end
  end
end
