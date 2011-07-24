#require "addressable/uri"
class FeedpostsController < ApplicationController

  before_filter :authenticate_user!, :except => [:show, :index]

  respond_to :html, :js

  def index
    feedposts_criteria = Mongoid::Criteria.new(Feedpost)
    feedposts_criteria.where(:id => params[:id]) if params[:id]
    feedposts_criteria.where(:feed_id => params[:feed_id]) if params[:feed_id]
    @feedposts = feedposts_criteria.execute

    #@feedposts = Feedpost.all
    respond_with(@feedposts)
  end

  def show
    @feedpost = Feedpost.find(params[:id])

    #@relatedfeeds = Feedpost.recents.limit(4)
    @relatedfeeds = Feedpost.search("title: "+@feedpost.title).facet('tags', :tags, :global => true).desc(:published).size(4)
    #@relatedfeeds = Feedpost.search("title: "+@feedpost.title).desc(:published).size(4)
    #debugger
    @postsites = Sitefeed.where(:feedpost_id => @feedpost.id)

    respond_with(@feedpost)
  end

  def new
    @feedpost = Feedpost.new
    respond_with(@feedpost)
  end

  def edit
    @feedpost = Feedpost.find(params[:id])
  end

  def create
    @feedpost = Feedpost.new(params[:feedpost])
    respond_with(@feedpost)
  end

  def update
    @feedpost = Feedpost.find(params[:id])
    @feedpost.update_attributes(params[:feedpost])
    respond_with(@feedpost)
  end

  def generatekeys
    @feedpost = Feedpost.find(params[:id])
    source = Readability::Document.new(@feedpost.content).content.summarize(:ratio => 100)

    source = AutoExcerpt.new(source, {:skip_paragraphs => 0, :paragraphs => 3, :ending => nil, :strip_html => true})
    debugger
    calais = SemExtractor::Calais.new(:api_key => 'a5fsx98qaeyxzcc3ps4yfses', :context => source)
    #zemanta = SemExtractor::Zemanta.new(:api_key => '6nmaz6nxeqpx9f7qzxecjh23', :context => source)
    #debugger
    puts zemanta.terms
    puts zemanta.categories
    #put calais.geos
  end

  def read
     @feedpost = Feedpost.find(params[:id])
     #answer
     t = Tropo::Generator.new(:voice => 'kate')
     #debugger
     t.say "Guess what, hello jason", :voice => 'kate'


     #redirect_to root_url
     t.response
     #t.say 'Hello!'
     
  end

  def vote
    @feedpost = Feedpost.find(params[:id])
    if current_user
      unless current_user.voted?(@feedpost)
        current_user.vote(@feedpost, :up)
      end
    end
  end

  def destroy
    @feedpost = Feedpost.find(params[:id])
    @feedpost.destroy

    respond_to do |format|
      format.html { redirect_to(feedposts_url) }
      format.xml  { head :ok }
    end
  end
end
