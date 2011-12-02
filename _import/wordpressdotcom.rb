# coding: utf-8

# Original File: https://github.com/mojombo/jekyll/blob/master/lib/jekyll/migrators/wordpress.rb
# Modified by Yu-Cheng Chuang <ducksteven@gmail.com>
# Licensed under MIT License (same as the original file)

# This version of wordpressdotcom.rb is compatible 
# with the real-world Wordpress.com export file, which:
#
# - Makes paragraphs (<p>) and line breaks (<br>) 
#   with simple_format borrowed from Ruby on Rails' ActionPack
#   (Wordpress.com does not actually store <p> tags)
# - Removes <br> in <pre>, which is usually unnecessary
# - Decodes encoded URI to avoid double-encoding of non-ascii slugs (permalink_title)
#   e.g. If you have a post with title "café",
#        Wordpress.com may already escaped the slug to "caf%C3%A9"
#        In this case, if you don't decode it to the original form,
#        The filename will be double-encoded to "caf%25C3%25A9"
#        and so the post URL (if you have :title in the URL format).
# - Disable Disqus comment for a post if commenting was disabled on that post.
# But does not support
# - [sourcecode language='blahblah'] block, please grep them out yourself.
# - Convert HTML to Markdown

require 'rubygems'
require 'hpricot'
require 'fileutils'
require 'psych'
require 'time'

module Jekyll
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressDotCom
    # From ActionPack of Ruby on Rails
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_view/helpers/text_helper.rb
    def self.simple_format(text)
      text = '' if text.nil?
      start_tag = "<p>"
      text = text.to_str
      text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
      text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
      text.gsub!(/([^>])(\n)([^\n<])/, '\1<br>\2\3')
      text.insert 0, start_tag
      text.concat("</p>")
    end

    def self.remove_br_in_pre(text)
      doc = Hpricot(text)
      doc.search("pre br").remove
      doc.to_s
    end

    def self.process(filename = "wordpress.xml")
      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename))

      (doc/:channel/:item).each do |item|
        title = item.at(:title).inner_text.strip
        permalink_title = item.at('wp:post_name').inner_text
        # Fallback to "prettified" title if post_name is empty (can happen)
        if permalink_title == ""
          permalink_title = title.downcase.split.join('-')
        end

        date = Time.parse(item.at('wp:post_date').inner_text)
        status = item.at('wp:status').inner_text

        if status == "publish" 
          published = true
        else
          published = false
        end

        comment_status = item.at('wp:comment_status').inner_text

        if comment_status == "open"
          comments = true
        else
          comments = false
        end

        type = item.at('wp:post_type').inner_text
        categories = (item/"category[@domain=category]").map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq
        tags = (item/"category[@domain=post_tag]").map{|t| t.inner_text}.uniq

        name = "#{date.strftime('%Y-%m-%d')}-#{URI.decode permalink_title}.html"
        header = {
          'layout' => type,
          'title'  => title,
          'categories'   => categories,
          'tags'   => tags,
          'published' => published,
          'comments' => comments
        }

        FileUtils.mkdir_p "source/_#{type}s"
        File.open("source/_#{type}s/#{name}", "w") do |f|
          f.puts header.to_yaml
          f.puts '---'
          f.puts remove_br_in_pre simple_format item.at('content:encoded').inner_text
        end

        import_count[type] += 1
      end

      import_count.each do |key, value|
        puts "Imported #{value} #{key}s"
      end
    end
  end
end
