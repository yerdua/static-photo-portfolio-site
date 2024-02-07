# TODO: Make this work at all, which I don't think it does
class RssFeed < Page
  TEMPLATE_FILENAME = "rss.xml.erb".freeze

  def file_destination
    File.join(SITE_DIR, "rss.xml")
  end

  def items
    @items ||= (Archive.new.albums + Blog.new.published_posts)
      .map do |i|
        Item.new(i)
      end
      .sort_by(&:published_at)
      .reverse
  end

  class Item
    attr_reader :title, :published_at, :image, :description, :url
    def initialize(post_or_album)
      if post_or_album.is_a?(ArchiveAlbum)
        @published_at = post_or_album.published_at || post_or_album.date
        @image = post_or_album.primary_photo.img_url(:medium)
        @description = post_or_album.description
      elsif post_or_album.is_a?(BlogPost)
        @published_at = post_or_album.published_at
        @image = post_or_album.header_image_url
        @description = post_or_album.excerpt
      end

      @description = @description.gsub("<p>", "").gsub("</p>", "")

      @title = post_or_album.title
      @url = post_or_album.url
    end
  end
end
