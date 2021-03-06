module ForumsHelper

  def strip_quote(text)
    simple_markdown(text).gsub(/<blockquote>(.*?)<\/blockquote>/m, '').strip
  end


  def simple_markdown(text, allow_links = true, target_blank = true, table_class = '')
    result = ''
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true, lax_spacing: true, space_after_headers: true, underline: true, highlight: true, footnotes: true )
    result = markdown.render(text.to_s)
    result = add_table_class(result, table_class) unless table_class.blank?
    # result = expand_relative_paths(result)
    # result = page_headers(result)
    result = replace_p_with_p_lead(result)
    result = remove_links(result) unless allow_links
    result = target_link_as_blank(result) if target_blank
    result = link_usernames(result)
    result.html_safe
  end

  def style_forum_post(text)
    (text).html_safe
  end

  def target_link_as_blank(text)
    text.to_s.gsub(/<a(.*?)>/, '<a\1 class="content-link" target="_blank">').html_safe
  end

  def remove_links(text)
    text.to_s.gsub(/<a href="(.*?)">(.*?)<\/a>/, '\1')
  end

  def replace_p_with_p_lead(text)
    text.to_s.gsub(/<p>/, '<p class="lead">').html_safe
  end

  def add_table_class(text, table_class)
    text.to_s.gsub(/<table>/, "<table class=\"#{table_class}\">").html_safe
  end

  def link_usernames(text)
    usernames = SocialProfile.current.where.not(name: [nil, '']).pluck(:name).uniq.sort
    result = text.to_s
    usernames.each do |username|
      result = result.gsub(/@#{username}\b/i, "<a href=\"#{ENV['website_url']}/forum?a=#{username}\">@#{username}</a>")
    end
    result.html_safe
  end

end
