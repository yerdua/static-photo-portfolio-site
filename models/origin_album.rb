class OriginAlbum
  attr_reader :folder, :photo_filenames

  def initialize(folder, destination_folder = nil)
    @folder = folder
    @local_folder = destination_folder
    @photo_filenames = Dir
      .children(File.join(folder, "web-medium"))
      .select do |filename|
        filename.end_with?("jpg")
      end
      .sort
  end

  def write_to_local_album
    ArchiveAlbum.new(local_folder, info).tap do |local_album|
      local_album.set_up_photo_folder_symlinks
      #squares
      puts("local dir: #{local_album.album_path}")
      make_square_photos!(local_album.album_path)
      local_album.copy_local_photos_to_bucket
    end
  end

  def write_to_preview_album(folder_name)
    PreviewAlbum.new(folder_name, info).tap do |preview_album|
      preview_album.set_up_photo_folder_symlinks
    end
  end

  def local_folder
    @local_folder ||= begin
      path_end = folder
        .split(/\/20\d{2}\/\d{2}[\w\s-]*\//)
        .last
        .gsub(/[^\w\/\s]/, "")
        .gsub(/\s+/, "_")
        .downcase
        .sub(/\/jp(e?)g$/, "")
        .gsub(/\//, "_")

      "#{info["date"].strftime("%Y%m")}#{path_end.start_with?(/\d/) ? path_end : "_#{path_end}"}"
    end
  end

  def info
    @info ||= begin
      source_info = if File.exist?(File.join(folder, "info.yml"))
        YAML.load(File.read(File.join(folder, "info.yml")))
      else
        {}
      end

      source_info["origin_folder"] = folder
      source_info["photo_bucket"] = DEFAULT_PHOTO_BUCKET
      source_info["date"] = implied_date_from_origin_path if implied_date_from_origin_path

      unless source_info.key?("photos")
        source_info["photos"] = {}.tap do |pinfo|
          photo_filenames.each do |photo_filename|
            pinfo[photo_filename] = {}
          end
        end
      end

      source_info
    end
  end

  def implied_date_from_origin_path
    if (date_match = folder.match(/20\d{2}\/\d{2}.*\/\d{2}/))
      puts("found date" + date_match.to_s)
      Date.parse(date_match.to_s)
    else
      puts("did not find a date")
      nil
    end
  end

  def make_square_photos!(destination_dir)
    info["photos"].keys.each do |filename|
      puts("copying #{filename}...")
      origin_photo = OriginPhoto.new(File.join(folder, "web-large"), filename)
      origin_photo.make_square(destination_dir)
    end
  end
end
