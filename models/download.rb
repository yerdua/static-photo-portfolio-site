class Download < Page
  TEMPLATE_FILENAME = "download_page.html.erb"

  DOWNLOADS_DIR = "downloads"

  attr_reader(
    :folder_name,
    :preview_path,
    :photo_filenames,
    :title,
    :public_album_link,
    :subject,
    :remote_zip_filename,
    :download_bucket
  )

  def self.create_download(human_readable_identifier: nil, info: {}, source_folder:)
    token = SecureRandom.hex(6)
    while Dir.children(File.join(SITE_DIR, DOWNLOADS_DIR)).include?(token)
      token = SecureRandom.hex
    end

    folder_name = [token, human_readable_identifier].compact.join("-")
    path = File.join(SITE_DIR, DOWNLOADS_DIR, folder_name)
    puts("creating folder: #{path}")
    FileUtils.mkdir_p(path)
    info["download_bucket"] = DEFAULT_DOWNLOAD_BUCKET

    remote_zip_filename = "#{folder_name}.zip"

    info["remote_zip_filename"] = File.join(info["download_bucket"]["url"], remote_zip_filename)

    File.write(File.join(path, "info.yml"), info.to_yaml)

    new(folder_name).tap do |new_download|
      new_download.create_zip_file(remote_zip_filename)
      new_download.upload_zip_file_to_bucket
    end
  end

  def self.create_download_for_subject(subject_key:, album:, source_folder: nil, title_slug: nil)
    photos = album.photos_for_subject(subject_key)
    subject = Subject.find_by(short_name: subject_key)
    source_folder ||= album.full_res_source
    info = {
      "preview_path" => File.join(album.photo_bucket_url, album.class::BASE_DIRECTORY, album.folder, "small"),
      "title" => "#{album.date} - #{album.title} - #{subject.display_name}",
      "public_album_link" => album.album_path,
      "full_res_source" => source_folder,
      "subject" => subject_key,
      "photo_filenames" => photos.map(&:filename)
    }

    create_download(
      human_readable_identifier: [title_slug, subject_key].compact.join("-"),
      info: info,
      source_folder: source_folder
    )
  end

  def self.create_download_for_album(album:, source_folder: nil, title_slug: nil)
    info = {
      "preview_path" => File.join(album.photo_bucket_url, album.class::BASE_DIRECTORY, album.folder, "small"),
      "title" => "#{album.date} - #{album.title}",
      "public_album_link" => album.album_path,
      "photo_filenames" => album.photos.map(&:filename)
    }

    create_download(
      human_readable_identifier: (title_slug || album.folder.split("/").last),
      info: info,
      source_folder: source_folder || album.full_res_source
    )
  end

  def initialize(folder_name)
    @folder_name = folder_name

    @preview_path, @photo_filenames, @title, @public_album_link, @subject_key, @remote_zip_filename, @download_bucket = info.values_at(
      "preview_path",
      "photo_filenames",
      "title",
      "public_album_link",
      "subject",
      "remote_zip_filename",
      "download_bucket"
    )

    @meta_property_tags = {
      "og:title" => "Audrey Penven | #{title}",
      "og:image" => [preview_path, photo_filenames.first].join("/")
    }

    @subject = Subject.find_by(short_name: @subject_key) if @subject_key
  end

  def info
    @info ||= YAML.load(
      ERB.new(File.read(File.join(local_dir_path, "info.yml"))).result
    )
  end

  def zip_file
    @zip_file ||= Dir.entries(local_dir_path).find do |filename|
      filename.end_with?("zip")
    end
  end

  def create_zip_file(filename)
    raise "already exists" if zip_file
    Zip::File.open(File.join(local_dir_path, filename), create: true) do |file|
      info["photo_filenames"].each do |photo|
        file.add(photo, File.join(info["full_res_source"], photo))
      end
    end
  end

  def upload_zip_file_to_bucket
    puts("uploading zipfile to the bucket")
    command = "rclone copyto #{local_zip_file_path} #{download_bucket["remote"]}:#{File.join(download_bucket["name"], info["remote_zip_filename"].split("/").last)} --copy-links --s3-acl=public-read --s3-storage-class=ONEZONE_IA --progress"
    puts("running command:")
    puts(command)
    output = `#{command}`
    puts(output)
  end

  def local_zip_file_path
    File.join(local_dir_path, zip_file)
  end

  def local_dir_path
    File.join(SITE_DIR, DOWNLOADS_DIR, folder_name)
  end

  def file_destination
    File.join(SITE_DIR, DOWNLOADS_DIR, folder_name, "index.html")
  end
end
