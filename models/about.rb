class About < Page
  TEMPLATE_FILENAME = 'about.html.erb'.freeze

  def initialize
    ensure_folder_exists!
    @meta_property_tags = {
      'og:title' => 'Audrey Penven | About',
      'og:url' => "#{SITE_BASE_URL}/about",
      'og:image' => "#{SITE_BASE_URL}/images/self-with-camera-circle.jpg",
    }
  end

  def file_destination
    File.join(folder_path, 'index.html')
  end

  private

  def folder_path
    File.join(SITE_DIR, 'about')
  end

  def ensure_folder_exists!
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)
  end
end