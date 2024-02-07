class InstaLinks < Page
  TEMPLATE_FILENAME = "instagram_links_template.html.erb"

  class Link
    attr_reader :display_name, :url, :label, :rel, :background_image, :identifier

    def initialize(display_name:, url:, label: nil, rel: nil, background_image: nil, identifier: nil)
      @display_name = display_name
      @url = url
      @label = label
      @rel = rel
      @background_image = background_image
      @identifier = identifier
    end

    def label_icon
      css_class = case label
      when "twitter"
        "fab fa-fw fa-twitter"
      when "mastodon"
        "fab fa-fw fa-brands fa-mastodon"
      when "instagram"
        "fab fa-fw fa-instagram"
      when "photo-album"
        "fas fa-camera"
      when "blog-post"
        "fas fa-comment-alt"
      when "website"
        "fas fa-globe"
      else
        "fas fa-link"
      end

      "<i class='#{css_class}'></i> "
    end

    def html_tag
      link_tag(
        display_name: li_tag { "#{label_icon}<span class='insta-link-text'>#{display_name}</span>" },
        url: url,
        rel: rel,
        id_attr: "a-#{@identifier}"
      )
    end

    def li_tag
      attrs = []

      attrs << "id='li-#{@identifier}'" unless @identifier.nil?
      attrs << (@background_image.nil? ? "class='insta-link'" : "class='insta-link insta-link-with-background'")

      "<li #{attrs.join(" ")}>#{yield}</li>"
    end

    def background_image
      @background_image ||= if label == "photo-album" && url.start_with?("/photography-archive")
        ArchiveAlbum.new(url).primary_photo.img_url(:small)
      else
        nil
      end
    end
  end

  attr_reader :links
  def initialize
    @links = YAML
      .load(
        ERB.new(File.read("config/insta_links.yml")).result
      )
      .map { |l|
        puts(l)
        Link.new(**l.symbolize_keys)
      }
  end

  def file_destination
    File.join(folder_path, "insta_links.html")
  end

  def folder_path
    SITE_DIR
  end
end
