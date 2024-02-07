class OriginPhoto
  attr_reader :folder, :filename

  def initialize(folder, filename)
    @folder = folder
    @filename = filename
  end

  def path
    File.join(folder, filename)
  end

  def make_square(destination_dir, options = {})
    pixels = Photo::SIZES[:square]
    MiniMagick::Tool::Convert.new do |convert|
      convert << path
      convert.merge!(
        [
          "-define",
          "jpeg:size=#{pixels}x#{pixels}",
          "-thumbnail",
          "#{pixels}x#{pixels}^",
          "-gravity",
          options[:gravity] || "center",
          "-extent",
          "#{pixels}x#{pixels}"
        ]
      )
      convert << File.join(SITE_DIR, destination_dir, "square", filename)
    end
  end
end
