class ArchiveAlbum < BaseAlbum
  TEMPLATE_FILENAME = "archive_album_template.html.erb".freeze
  RSS_TEMPLATE_FILENAME = "archive_album_rss_template.xml.erb".freeze

  BASE_DIRECTORY = "photography-archive".freeze

  # defined in BaseAlbum:
  # attr_reader
  #     :info,
  #     :folder,
  #     :title,
  #     :description,
  #     :flickr_url,
  #     :photo_info,
  #     :shared_photo_description,
  #     :date,
  #     :start_date,
  #     :end_date,
  #     :location,
  #     :origin_folder,
  #     :photo_bucket

  attr_reader :published_at

  def initialize(folder, new_info = nil)
    @folder = File.join(folder.split("/").reject { |x| x == BASE_DIRECTORY })

    ensure_folder_exists!
    ensure_photo_folders_exist!

    if new_info
      puts(new_info)
      File.write(File.join(local_dir_path, "info.yml"), new_info.to_yaml)
      puts("should have written the info file")
    end

    super(folder)
  end

  def photo_files_present?
    photo_folders.all? do |photo_folder|
      Dir
        .entries(photo_folder)
        .select do |e|
          e.end_with?("jpg")
        end
        .sort == photo_info.keys.sort
    end
  end

  def write_pages!
    write_page!
    photos.each(&:write_page!)
    return
  end

  private

  def ensure_folder_exists!
    FileUtils.mkdir_p(local_dir_path) unless Dir.exist?(folder)
  end

  def ensure_photo_folders_exist!
    square_dir = File.join(local_dir_path, "square")
    FileUtils.mkdir_p(square_dir) unless Dir.exist?(square_dir)
  end

  def photo_folders
    Photo::SIZES.keys.map do |size|
      File.join(local_dir_path, size.to_s)
    end
  end
end
