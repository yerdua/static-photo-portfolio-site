# Data dir should be in the format of
class BlogPost < Page
  TEMPLATE_FILENAME = "blog_post_template.html.erb".freeze
  RSS_TEMPLATE_FILENAME = "blog_post_rss_template.xml.erb".freeze

  BASE_DATA_DIR = File.join(DATA_DIR, "blog").freeze

  DEFAULT_HEADER_IMAGE = "/images/blog.jpg".freeze

  attr_reader :info, :source_folder_name

  def self.new_draft(slug)
    new("DRAFT-#{slug}")
  end

  def initialize(source_folder_name)
    @source_folder_name = source_folder_name
    ensure_source_folder_and_files_exist!

    @meta_property_tags = {
      "og:title" => "Audrey Penven | #{title}",
      "og:url" => "#{SITE_BASE_URL}#{relative_url}",
      "og:image" => "#{SITE_BASE_URL}#{header_image_url || DEFAULT_HEADER_IMAGE}"
    }
  end

  def info
    @info ||= YAML.load(File.read(info_file_path))
  end

  def created_at
    info["created_at"]
  end

  def title
    info["title"]
  end

  def write_info_to_file!
    File.write(info_file_path, info.to_yaml)
    @info = YAML.load(File.read(info_file_path))
  end

  def content
    ERB.new(File.read(content_file_path)).result(binding)
  end

  def excerpt
    content.split("<!-- end excerpt -->")[0]
  end

  def header_image_url
    info["header_image_url"]
  end

  def draft?
    source_folder_name.start_with?("DRAFT")
  end

  def published_at
    info["published_at"]
  end

  def slug
    source_folder_name.gsub(/^(DRAFT|\d{8,12})-/, "")
  end

  def file_destination
    if draft?
      File.join(folder_path, "drafts", "#{slug}.html")
    else
      File.join(folder_path, "#{source_folder_name}.html")
    end
  end

  def prep_for_publish!
    info["published_at"] = DateTime.now
    write_info_to_file!

    new_folder_name = "#{published_at.strftime("%Y%m%d%H%M")}-#{slug}"

    FileUtils.mv(source_folder_path, File.join(BASE_DATA_DIR, new_folder_name))
    @source_folder_name = new_folder_name
  end

  def source_files_modified_at
    [File.mtime(content_file_path), File.mtime(info_file_path)].max
  end

  def source_changes_since_last_write?
    page_last_written_at.nil? || page_last_written_at < source_files_modified_at
  end

  def write_page_if_changed!
    write_page! if source_changes_since_last_write?
  end

  def to_xml
  end

  private

  def folder_path
    File.join(SITE_DIR, "blog")
  end

  def source_folder_path
    File.join(BASE_DATA_DIR, source_folder_name)
  end

  def info_file_path
    File.join(source_folder_path, "info.yml")
  end

  def content_file_path
    File.join(source_folder_path, "content.html.erb")
  end

  def ensure_source_folder_and_files_exist!
    puts(source_folder_path)
    FileUtils.mkdir_p(source_folder_path) unless Dir.exist?(source_folder_path)
    unless File.exists?(info_file_path)
      File.write(
        info_file_path,
        {
          "title" => "",
          "created_at" => DateTime.now
        }.to_yaml
      )
    end

    FileUtils.touch(content_file_path) unless File.exists?(content_file_path)
  end
end
