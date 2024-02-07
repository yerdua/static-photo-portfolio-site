class Portfolio < Page
  TEMPLATE_FILENAME = "portfolio_index_template.html.erb".freeze
  CONFIG_FILENAME = File.join(CONFIG_DIR, "portfolio_list.yml").freeze

  def file_destination
    File.join(folder_path, "index.html")
  end

  def albums
    @albums ||= YAML.load(File.read(CONFIG_FILENAME)).map do |folder|
      PortfolioAlbum.new(folder)
    end
  end

  def write_album_pages!
    albums.each(&:write_page!)
  end

  private

  def folder_path
    File.join(SITE_DIR, "photography-portfolio")
  end
end
