module ApplicationHelper

  def errors_for(object, message=nil)
    html = ""
    unless object.errors.blank?
      html << "<div class='formErrors #{object.class.name.humanize.downcase}Errors'>\n"
      if message.blank?
        if object.new_record?
          html << "\t\t<h5>There was a problem creating the #{object.class.name.humanize.downcase}</h5>\n"
        else
          html << "\t\t<h5>There was a problem updating the #{object.class.name.humanize.downcase}</h5>\n"
        end    
      else
        html << "<h5>#{message}</h5>"
      end  
      html << "\t\t<ul>\n"
      object.errors.full_messages.each do |error|
        html << "\t\t\t<li>#{error}</li>\n"
      end
      html << "\t\t</ul>\n"
      html << "\t</div>\n"
    end
    html
  end  

  def markdownify(message, options = {})
    message = h(message).html_safe

    if !options.has_key?(:newlines)
      options[:newlines] = true
    end

    message = process_links(message)
    message = process_youtube(message)
    message = process_autolinks(message)
    message = process_emphasis(message)
    message = process_youtube_again(message, options[:youtube_maps])
    message = process_vimeo(message, options[:vimeo_maps])

    if options[:newlines]
      message.gsub!(/\n+/, '<br />')
    end

    return message
  end

  def process_links(message)
    message.gsub!(/\[([^\[]+)\]\(([^ ]+) \&quot;(([^&]|(&[^q])|(&q[^u])|(&qu[^o])|(&quo[^t])|(&quot[^;]))+)\&quot;\)/) do |m|
      escape = "\\"
      link = $1
      url = $2
      title = $3
      url.gsub!("_", "\\_")
      url.gsub!("*", "\\*")
      protocol = (url =~ /^\w+:\/\//) ? '' :'http://'
      res    = "<a target=\"#{escape}_blank\" href=\"#{protocol}#{url}\" title=\"#{title}\">#{link}</a>"
      res
    end
    message.gsub!(/\[([^\[]+)\]\(([^ ]+)\)/) do |m|
      escape = "\\"
      link = $1
      url = $2
      url.gsub!("_", "\\_")
      url.gsub!("*", "\\*")
      protocol = (url =~ /^\w+:\/\//) ? '' :'http://'
      res    = "<a target=\"#{escape}_blank\" href=\"#{protocol}#{url}\">#{link}</a>"
      res
    end

    return message
  end

  def process_youtube(message)
    message.gsub!(/( |^)(http:\/\/)?www\.youtube\.com\/watch[^ ]*v=([A-Za-z0-9_]+)(&[^ ]*|)/) do |m|
      res = "#{$1}youtube.com::#{$3}"
      res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
      res
    end
    return message
  end

  def process_autolinks(message)
    message.gsub!(/( |^)(www\.[^\s]+\.[^\s])/, '\1http://\2')
    message.gsub!(/(<a target="\\?_blank" href=")?(https|http|ftp):\/\/([^\s]+)/) do |m|
      if !$1.nil?
        m
      else
        res = %{<a target="_blank" href="#{$2}://#{$3}">#{$3}</a>}
        res.gsub!(/(\*|_)/) { |m| "\\#{$1}" }
        res
      end
    end
    return message
  end

  def process_emphasis(message)
    message.gsub!("\\**", "-^doublestar^-")
    message.gsub!("\\__", "-^doublescore^-")
    message.gsub!("\\*", "-^star^-")
    message.gsub!("\\_", "-^score^-")
    message.gsub!(/(\*\*\*|___)(.+?)\1/m, '<em><strong>\2</strong></em>')
    message.gsub!(/(\*\*|__)(.+?)\1/m, '<strong>\2</strong>')
    message.gsub!(/(\*|_)(.+?)\1/m, '<em>\2</em>')
    message.gsub!("-^doublestar^-", "**")
    message.gsub!("-^doublescore^-", "__")
    message.gsub!("-^star^-", "*")
    message.gsub!("-^score^-", "_")
    return message
  end

  def process_youtube_again(message, youtube_maps)
    while youtube = message.match(/youtube\.com::([A-Za-z0-9_\\\-]+)/)
      video_id = youtube[1]
      if youtube_maps && youtube_maps[video_id]
        title = youtube_maps[video_id]
      else
        title = I18n.t 'application.helper.video_title.unknown'
      end
      message.gsub!('youtube.com::'+video_id, '<a class="video-link" data-host="youtube.com" data-video-id="' + video_id + '" href="#video">Youtube: ' + title + '</a>')
    end
    return message
  end


  def process_vimeo(message, vimeo_maps)
    regex = /https?:\/\/(?:w{3}\.)?vimeo.com\/(\d{6,})/
    while vimeo = message.match(regex)
      video_id = vimeo[1]
      if vimeo_maps && vimeo_maps[video_id]
        title = vimeo_maps[video_id]
      else
        title = I18n.t 'application.helper.video_title.unknown'
      end
      message.gsub!(vimeo[0], '<a class="video-link" data-host="vimeo.com" data-video-id="' + video_id + '" href="#video">Youtube: ' + title + '</a>')
    end
    return message
  end

  def display_flash
    flash_types = [:error, :warning, :notice]
 
    messages = ((flash_types & flash.keys).collect do |key|
      "$.jGrowl('#{flash[key]}', { header: '#{I18n.t(key, :default => key.to_s)}', theme: '#{key.to_s}'});"
    end.join("\n"))
 
    if messages.size > 0
      content_tag(:script, :type => "text/javascript") do
        "$(document).ready(function() { #{messages} });"
      end
    else
      ""
    end
  end

end

