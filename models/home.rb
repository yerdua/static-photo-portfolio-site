class Home < Page
  TEMPLATE_FILENAME = 'home.html.erb'

  def initialize
    @meta_property_tags = {}
  end

  def file_destination
    File.join(folder_path, 'index.html')
  end

  def folder_path
    SITE_DIR
  end
end