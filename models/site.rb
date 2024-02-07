class Site
  attr_reader :archive, :portfolio, :about, :blog, :home, :error_page, :insta_links
  def initialize
    @archive = Archive.new
    @portfolio = Portfolio.new
    @about = About.new
    @blog = Blog.new
    @home = Home.new
    @error_page = ErrorPage.new
    @insta_links = InstaLinks.new
  end

  def regenerate_everything!
    %i(archive portfolio about home error_page insta_links).each do |section_name|
      regenerate_section!(section_name)
    end
  end


  def regenerate_section!(section_name)
    puts "Regenerating #{section_name}"
    section = public_send(section_name)
    section.write_page!

    section.write_album_pages! if section.respond_to?(:write_album_pages!)
    section.rewrite_all_published_posts! if section.respond_to?(:rewrite_all_published_posts!)
  end
end