class Location < ActiveRecord::Base

  def details
    details = [city, state, country].compact.join(", ")
  end
end
