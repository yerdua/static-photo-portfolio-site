class Blog < Page
  TEMPLATE_FILENAME = 'blog_template.html.erb'.freeze
  DATA_DIR = File.join(DATA_DIR, 'blog').freeze

  # TODO: deal with pagination
  POSTS_PER_PAGE = 10

  def initialize
    ensure_folder_exists!
    @meta_property_tags = {
      'og:title' => 'Audrey Penven | Blog',
      'og:url' => "#{SITE_BASE_URL}/blog",
      'og:image' => "#{SITE_BASE_URL}/images/blog.jpg"
    }
  end

  def file_destination
    File.join(folder_path, 'index.html')
  end

  def published_post_folders
    Dir.children(DATA_DIR).
      reject { |child| child.start_with?('DRAFT-') || child.start_with?('.') }.
      sort { |a, b| b <=> a }
  end

  def draft_post_folders
    Dir.children(DATA_DIR).select { |child| child.start_with?('DRAFT-') }
  end

  def draft_posts
    draft_post_folders.map { |fld| BlogPost.new(fld) }
  end

  def published_posts
    published_post_folders.map { |fld| BlogPost.new(fld) }
  end

  def write_published_posts_if_necessary!
    published_posts.each(&:write_page_if_changed!)
  end

  def rewrite_all_published_posts!
    published_posts.each(&:write_page!)
  end

  # def create_files_for_new_post(title, slug, datetime_override = nil)
  #   date = date_override || DateTime.now

  #   info = {
  #     title: title,
  #     slug: slug
  #   }
  # end

  private

  def folder_path
    File.join(SITE_DIR, 'blog')
  end

  def ensure_folder_exists!
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)
  end
end