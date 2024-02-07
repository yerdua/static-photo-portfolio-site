# PortfolioAlbum differs from the base Album in a few ways:
# - it might be made up of photos in several different folders.
# - it may not have a date
class PortfolioAlbum < BaseAlbum
  TEMPLATE_FILENAME = "portfolio_album_template.html.erb".freeze
  BASE_DIRECTORY = "photography-portfolio"

  # defined in BaseAlbum:
  # attr_reader
  #     :info,
  #     :folder,
  #     :title,
  #     :description,
  #     :flickr_url,
  #     :photo_info,
  #     :shared_photo_description,
  #     :date,
  #     :start_date,
  #     :end_date,
  #     :location,
  #     :origin_folder,
  #     :photo_bucket

  def initialize(folder)
    super
  end

  def identifier
    @identifier ||= File.split(folder).last
  end
end
