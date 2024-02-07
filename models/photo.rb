class Photo < Page
  TEMPLATE_FILENAME = "photo_template.html.erb".freeze

  SIZES = {
    large: 2000,
    medium: 1000,
    small: 300,
    square: 200
  }
  attr_reader(
    :album,
    :folder,
    :filename,
    :title,
    :description,
    :date,
    :next_filename,
    :previous_filename,
    :subjects,
    :location
  )

  def self.img_filename_to_page(fname)
    "#{fname.split(".")[0]}.html"
  end

  def initialize(album:, folder: nil, filename:, **attributes)
    @album = album
    @folder = folder || @album.album_path
    @filename = filename

    attributes.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end

    @meta_property_tags = {
      "og:title" => title || album&.title,
      "og:url" => [SITE_BASE_URL, page_path].join,
      "og:image" => img_url(:medium)
    }
  end

  def date
    @date || album&.date
  end

  def img_path(size)
    File.join("", folder, size.to_s, filename)
  end

  def img_base_url
    @img_base_url ||= (album&.photo_bucket&.[]("url") || SITE_BASE_URL)
  end

  def img_url(size, relative_if_possible = true)
    if relative_if_possible && img_base_url == SITE_BASE_URL
      img_path(size)
    else
      File.join(img_base_url, img_path(size)).to_s
    end
  end

  def location
    @location || album.location
  end

  def page_path
    return nil unless album
    File.join("", relative_folder_path)
  end

  def prev_path
    if previous_filename
      Photo.img_filename_to_page(previous_filename)
    end
  end

  def next_path
    if next_filename
      Photo.img_filename_to_page(next_filename)
    end
  end

  # returns [x,y] or [width, height]
  def aspect_ratio
    @aspect_ratio ||= begin
      img = MiniMagick::Image.open(File.join(SITE_DIR, img_path(:medium)))
      [img.width.to_f / SIZES[:medium], img.height.to_f / SIZES[:medium]]
    end
  end

  def is_35mm?
    [[1.0, 0.667], [0.667, 1.0]].include?(aspect_ratio)
  end

  def orientation
    case aspect_ratio[0] <=> aspect_ratio[1]
    when 1
      "horizontal"
    when 0
      "square"
    when -1
      "vertical"
    end
  end

  def dimensions(size)
    aspect_ratio.map { |num| (num * SIZES[size]).to_i }
  end

  private

  def relative_folder_path
    return nil unless album
    File.join(folder, Photo.img_filename_to_page(filename))
  end

  def file_destination
    return nil unless album
    File.join(SITE_DIR, relative_folder_path)
  end
end
