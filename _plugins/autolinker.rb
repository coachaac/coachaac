# Use [Some Page] to automatically build a verified link to that page.
# Use [Alt text,Some Page] to do the same but override the anchor text.
#
# Note: wrap your content with {{ content | autolink }} to enable this.
module Autolinker
  def autolink(input)
    input ||= ''
    site = @context.registers[:site]
    # at this point we have no more markdown but only html
    input.gsub(/\[([^\]]+)\]/) do |match|
      tokens = $1.split(',')
      raise "Forbidden match #{match}" unless tokens.size.between?(1, 2)
      target_post_title = tokens.pop.gsub('&amp;','and')
      overriding_text = tokens.pop
      slugified_target_post_title = Jekyll::Utils.slugify(target_post_title)
      Jekyll.logger.debug "Looking for page with slug #{slugified_target_post_title.inspect}"
      target_post = site.posts.docs.find do |p|
        p.data['slug'] == slugified_target_post_title
      end
      raise "No internal page match found for #{match}" unless target_post
      anchor_text = overriding_text || target_post['title']
      Jekyll.logger.debug "Auto-linking to #{target_post.url}"
      "<a href='#{site.baseurl}#{target_post.url}'>#{anchor_text}</a>"
    end
  end
end

Liquid::Template.register_filter(Autolinker)
