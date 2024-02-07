class Archive < Page
  attr_reader :folders

  TEMPLATE_FILENAME = "archive_index_template.html.erb".freeze
  CONFIG_FILENAME = File.join(CONFIG_DIR, "archive_list.yml").freeze

  def file_destination
    File.join(folder_path, "index.html")
  end

  def albums
    @albums ||= YAML
      .load(File.read(CONFIG_FILENAME))
      .map { |folder| ArchiveAlbum.new(folder) }
  end

  def write_album_pages!
    albums.each(&:write_pages!)
  end

  def folder_path
    File.join(SITE_DIR, "photography-archive")
  end
end
