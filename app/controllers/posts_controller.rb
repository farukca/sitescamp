class PostsController < ApplicationController

  before_filter :authenticate_user!, :except => [:search, :show, :index]

  respond_to :html

  def index
    @posts = Post.find(:all, :conditions => {:site_id => params[:site_id]}).paginate(:all, :per_page => 5, :page => params[:page])
  end
  
  def create
    params[:post][:user_id] = current_user.id
    #@post.user_id = current_user.id
    @post = Post.create!(params[:post])

    respond_to do |format|
      format.html {redirect_to @post.site}
      format.js
    end
  end

  def self.get_site_posts(siteid)
    if !siteid.blank?
       where(:site_id => siteid)
    else
       all
    end
  end

end

