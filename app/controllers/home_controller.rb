class HomeController < ApplicationController

  def index

    if current_user && !current_user.person.nil?
      #if current_user.profile_updated
         redirect_to person_path(current_user.person)
      #else
      #   redirect_to edit_person_path(current_user.person)
      #end
    else
      @sites = Site.limit(3).descending(:created_at)
      @sliderposts = Feedpost.with_images.only(:id,:feed_id,:title,:author,:summary,:published,:images).order_by(:published, :desc).limit(6).cache
      @feedposts = Feedpost.with_images.only(:id,:feed_id,:title,:author,:summary,:published,:images).order_by(:published, :desc).skip(6).limit(6).cache
      @newfeeds = Feed.where(:status => 'A').descending(:created_at).limit(10)
    end
    @categories = Category.desc(:score).limit(4).cache
  end

  def search
    searchTxt  = params[:searchfield]
    unless searchTxt.to_s.blank?
      @feedposts = Mebla.search("title: "+searchTxt, :page => (params[:page] || 1)).desc(:published).size(50)#.page params[:page]
    end 
  end
end
