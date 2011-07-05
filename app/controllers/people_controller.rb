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
    if not str_ids.blank?
      #@feedposts = Feedpost.only(:id,:feed_id,:title,:content,:author,:published,:images).any_in(:feed_id => str_ids).limit(20).descending(:published).paginate(:per_page => 6, :page => params[:page])
      @feedposts = Feedpost.recents.postsbyfeeds(str_ids).descending("published").page params[:page]
    end

    #other feeds
    @recommendedfeeds = Feed.only(:id,:title).not_in(:_id => str_ids).descending(:created_at).limit(10)


    # source people entries
    str_ids = @person.person_source_ids("P")
    if not str_ids.blank?
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

  def follow
    @person  = current_user.person
    group = params[:group_id]
    @feed = Feed.find(params[:feed_id])
    if not @feed.nil?
      if not group.to_s.blank?
        @grpfeed = Groupfeed.create!(
          :group_id  => group,
          :person_id => @person.id,
          :feed_id   => @feed.id
        )
      end

      @person.add_feed_to_follow(@feed)
    end
    respond_with @grpfeed, :notice => "Feed added to Group"
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

end
