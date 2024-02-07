class Page
  def initalize
    @meta_property_tags = {}
  end

  def template
    File.read(template_path)
  end

  def rss_template
    File.read(rss_template_path)
  end

  def template_path
    File.join(TEMPLATES_DIR, self.class::TEMPLATE_FILENAME)
  end

  def rss_template_path
    File.join(TEMPLATES_DIR, self.class::RSS_TEMPLATE_FILENAME)
  end

  def render
    ERB.new(template).result(binding)
  end

  def to_rss_item
    raise "No RSS template" unless File.exists?(rss_template_path)

    ERB.new(rss_template).result(binding)
  end

  def write_page!
    File.write(file_destination, render)
  end

  def page_last_written_at
    File.mtime(file_destination) if File.exists?(file_destination)
  end

  def file_destination
    raise "Must define this on the inheriting class"
  end

  def meta_property_tags
    if @meta_property_tags
      default_meta_property_tags.merge(@meta_property_tags)
    else
      default_meta_property_tags
    end
  end

  def default_meta_property_tags
    {
      "og:type" => "website",
      "og:title" => "Audrey Penven",
      "og:url" => url,
      "og:image" => "#{SITE_BASE_URL}/images/audreypenven-net-og-img.png"
    }
  end

  def url
    URI.join(SITE_BASE_URL, relative_url).to_s
  end

  def relative_url
    file_destination.gsub(SITE_DIR, "").gsub(/index.html$/, "")
  end
end
