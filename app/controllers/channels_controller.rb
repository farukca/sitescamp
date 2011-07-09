class ChannelsController < ApplicationController

  respond_to :html, :js

  def index
    @channels = Channel.all

  end

  def show
    @channel = Channel.find(params[:id])

    respond_with @feed
  end

  def new
    @channel = Channel.new

    respond_with @feed
  end

  def add_feed
    @channel = Channel.find(params[:id])
    feed_id  = params[:feed]
    if @channel.add_feed_to_channel(feed_id)
      respond_with @channel, :notice => 'Channel was successfully updated.'
    else
    end

  end

  def edit
    @channel = Channel.find(params[:id])
  end

  def create
    @category = Category.find(params[:category_id])
    @channel = @category.channels.create(params[:channel])

    redirect_to category_path(@category)

  end

  def update
    @channel = Channel.find(params[:id])

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
         respond_with @feed, :notice => 'Channel was successfully updated.'
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to(channels_url) }
      format.xml  { head :ok }
    end
  end
end
