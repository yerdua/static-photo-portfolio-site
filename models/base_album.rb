class BaseAlbum < Page
  attr_reader(
    :info,
    :folder,
    :title,
    :description,
    :flickr_url,
    :photo_info,
    :shared_photo_description,
    :date,
    :start_date,
    :end_date,
    :location,
    :origin_folder,
    :photo_bucket
  )
  attr_accessor :draft

  def initialize(folder)
    @folder = folder.gsub(SITE_DIR, "").gsub(self.class::BASE_DIRECTORY, "").gsub(/^\/+/, "").gsub(/\/+$/, "")

    @title, @description, @flickr_url, @photo_info, @shared_photo_description, @date, @start_date, @end_date, @location, @origin_folder, @published_at, @photo_bucket = info.values_at(
      "title",
      "description",
      "flickr_url",
      "photos",
      "shared_photo_description",
      "date",
      "start_date",
      "end_date",
      "location",
      "origin_folder",
      "published_at",
      "photo_bucket"
    )

    @date ||= @start_date

    @meta_property_tags = {
      "og:title" => "Audrey Penven | #{title}",
      "og:url" => album_url,
      "og:image" => primary_photo.img_url(:medium)
    }
    @draft = false
  end

  def photos
    @photos ||= photo_info.keys.map.with_index do |filename, index|
      attributes = {
        previous_filename: index.zero? ? nil : photo_info.keys[index - 1],
        next_filename: photo_info.keys[index + 1],
        filename: filename,
        album: self
      }.merge(
        photo_info[filename].slice("title", "description", "date", "folder", "subjects", "location")
      )

      Photo.new(**attributes)
    end
  end

  def primary_photo
    @primary_photo ||= if info["primary_photo"]
      photos.find { |ph| ph.filename == info["primary_photo"] }
    else
      photos.first
    end
  end

  def header_photo
    @header_photo ||= if info["header_photo"]
      photos.find { |ph| ph.filename == info["header_photo"] }
    else
      primary_photo
    end
  end

  def info
    @info ||= YAML.load(
      ERB.new(File.read(File.join(local_dir_path, "info.yml"))).result
    )
  end

  def full_res_source
    File.join(origin_folder, "fullres-jpg")
  end

  def subjects
    @subjects ||= photos.map(&:subjects).flatten.compact.uniq
  end

  def photos_grouped_by_subject
    @photos_grouped_by_subject ||= begin
      groups = {}.tap { |g| g.default = [] }

      photos.each do |photo|
        next unless photo.subjects
        photo.subjects.each do |subj|
          groups[subj] += [photo]
        end
      end

      groups
    end
  end

  def photos_for_subject(subject_key)
    photos_grouped_by_subject[subject_key]
  end

  def replace_photo_folders_with_symlinks(source_folder = nil)
    source_folder ||= info["origin_folder"]
    raise "no source folder found" if source_folder.nil?

    %w[small medium large].each do |size|
      size_source_folder = File.join(source_folder, "web-#{size}")
      size_local_folder = File.join(local_dir_path, size)
      if File.directory?(size_source_folder)
        if File.symlink?(size_local_folder)
          puts("Symlink is already set up for #{size}")
        else
          File.rename(size_local_folder, "#{size_local_folder}-backup")
          File.symlink(size_source_folder, size_local_folder)

          puts("successfully symlinked #{size_local_folder}")
          FileUtils.rm_rf("#{size_local_folder}-backup")
        end
      else
        puts("Could not symlink #{size} because source does not exist at #{size_source_folder}")
      end
    end
  end

  def set_up_photo_folder_symlinks
    source_folder = info["origin_folder"]

    %w[small medium large].each do |size|
      size_source_folder = File.join(source_folder, "web-#{size}")
      size_local_folder = File.join(local_dir_path, size)

      if File.directory?(size_source_folder)
        if File.symlink?(size_local_folder)
          puts("Symlink is already set up for #{size}")
        else
          File.symlink(size_source_folder, size_local_folder)
          puts("successfully symlinked #{size_local_folder}")
        end
      else
        puts("Could not symlink #{size} because source does not exist at #{size_source_folder}")
      end
    end
  end

  def copy_local_photos_to_bucket
    raise "no bucket defined" if photo_bucket.blank?

    %w[small medium large square].each do |size|
      size_local_folder = File.join(local_dir_path, size, "")
      output = `rclone copy #{size_local_folder} #{photo_bucket_remote}:#{File.join(photo_bucket_name, album_path, size)} --copy-links --s3-acl=public-read --s3-storage-class=ONEZONE_IA --progress`
      puts(output)
    end
  end

  def album_path
    File.join("", self.class::BASE_DIRECTORY, folder)
  end

  def album_url
    URI.join(SITE_BASE_URL, album_path).to_s
  end

  def file_destination
    File.join(local_dir_path, "index.html")
  end

  def local_dir_path
    File.join(SITE_DIR, self.class::BASE_DIRECTORY, folder)
  end

  def photo_bucket_remote
    @photo_bucket_remote ||= photo_bucket && photo_bucket["remote"]
  end

  def photo_bucket_name
    @photo_bucket_name ||= photo_bucket && photo_bucket["name"]
  end

  def photo_bucket_url
    @photo_bucket_url ||= photo_bucket && photo_bucket["url"]
  end
end
