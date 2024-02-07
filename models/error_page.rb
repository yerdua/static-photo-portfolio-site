class ErrorPage < Page
  TEMPLATE_FILENAME = '404.html.erb'

  def initialize
    @meta_property_tags = {
      'og:title' => 'Audrey Penven | 404 Not Found',
    }
  end

  def file_destination
    File.join(SITE_DIR, '404.html')
  end
end