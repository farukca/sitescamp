class PeopleController < ApplicationController

  before_filter :authenticate_user!

  respond_to :html, :js

  def index

    @people = Person.search(params[:q]).paginate :page => params[:page], :per_page => 25, :order => 'created_at DESC'

  end

  def show
    @person  = Person.find(params[:id])
    #refl = Person.validators
    #debugger
    # source feeds entries
    str_ids = @person.person_source_ids("F")
    #debugger
    if str_ids.blank?
      #user does not have feed to follow, this time it will work like home index controller
      @sliderposts = Feedpost.with_images.only(:id,:feed_id,:title,:author,:published,:images).order_by(:published, :desc).limit(6).cache
      @feedposts = Feedpost.with_images.only(:id,:feed_id,:title,:author,:published,:images).order_by(:published, :desc).skip(6).limit(6).cache
      @newfeeds = Feed.where(:status => 'A').descending(:created_at).limit(10)
    else
      #@feedposts = Feedpost.only(:id,:feed_id,:title,:content,:author,:published,:images).any_in(:feed_id => str_ids).limit(20).descending(:published).paginate(:per_page => 6, :page => params[:page])
      @sliderposts = Feedpost.postsbyfeeds(str_ids).only(:id,:feed_id,:title,:author,:published,:images).order_by(:published, :desc).limit(6).cache
      @feedposts = Feedpost.recents.postsbyfeeds(str_ids).only(:id,:feed_id,:title,:author,:published,:images).order_by(:published, :desc).skip(6).limit(6).cache
    #.page params[:page]
    end

    #other feeds
    @newfeeds = Feed.only(:id,:title).not_in(:_id => str_ids).descending(:created_at).limit(10)


    # source people entries
    str_ids = @person.person_source_ids("P")
    unless str_ids.blank?
      @posts = Post.any_in(:person_id => str_ids)
    end

    #user groups
    @usergroups   = @person.usergroups.all.ascending(:title)

    #related sites
    @sites   = Site.limit(3).descending(:created_at)
    
    #@personfeeds = Personfeed.where(:person_id => @person.id).order_by(:created_at.desc)

    #@posts  = current_user.visible_posts(:_type => "StatusMessage").paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
    #@post_hashes = hashes_for_posts @posts
    #@contacts = Contact.all(:user_id => current_user.id, :pending => false)
    
    #@contact_hashes = hashes_for_contacts @contacts

    #if current_user.first_time == true
    #  redirect_to getting_started_path
    #end
  end

  def profile
    @person  = Person.find(params[:id])
    @posts   = Post.where(:user_id => @person.user_id).order_by(:created_at.desc).paginate(:per_page => 8, :page => params[:page])
    str_ids = @person.person_source_ids("F")
    @feeds   = Feed.all_in(:id => str_ids).ascending(:title)
  end

  def addgroup
    @person  = current_user.person
    group_title = params[:group]
    if not group_title.to_s.blank?
      @group = @person.add_group(group_title)
      respond_with @group, :notice => 'Group added succesfully'
    end
  end

  def dashboard
    @person  = Person.find(params[:id])
    str_ids = @person.person_source_ids("F")
    unless str_ids.blank?
      @feedposts = Feedpost.postsbyfeeds(str_ids).only(:id,:feed_id,:title,:author,:published,:images,:summary).order_by(:published, :desc).page params[:page]
    end
    @feeds = Feed.where(:_id.in => Feedpost.today.distinct(:feed_id))
  end

  def edit
    @person  = current_user.person
  end

 def update
    @person = current_user.person
    @person.profile_updated = true
    if @person.update_attributes(params[:person])
      flash[:notice] = I18n.t 'people.update.updated'
      redirect_to root_url
    else
      flash[:error] = I18n.t 'people.update.failed'
      redirect_to edit_person_path
    end
  end

  def todaysfeed
    todayfeeds = []
    todayfeeds = Feedpost.today.distinct(:feed_id)
    return todayfeeds.to_s
  end

end
