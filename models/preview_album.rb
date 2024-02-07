class PreviewAlbum < BaseAlbum
  TEMPLATE_FILENAME = "preview_album_template.html.erb".freeze
  BASE_DIRECTORY = "previews"

  # defined in BaseAlbum:
  # attr_reader
  #   :info,
  #   :folder,
  #   :title,
  #   :description,
  #   :flickr_url,
  #   :photo_info,
  #   :shared_photo_description,
  #   :date,
  #   :start_date,
  #   :end_date,
  #   :location,
  #   :origin_folder,
  #   :photo_bucket

  def initialize(folder_name, new_info = nil)
    @folder = File.join(BASE_DIRECTORY, folder_name)

    ensure_folder_exists!

    if new_info
      File.write(File.join(SITE_DIR, folder, "info.yml"), new_info.to_yaml)
    end

    super(folder)
  end

  def ensure_folder_exists!
    FileUtils.mkdir_p(File.join(SITE_DIR, folder)) unless Dir.exist?(folder)
  end

  def zip_file
    @zip_file ||= Dir.entries(local_dir_path).find do |filename|
      filename.end_with?("zip")
    end
  end
end
