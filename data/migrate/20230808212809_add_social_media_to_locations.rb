class AddSocialMediaToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column(:locations, :instagram, :string)
    add_column(:locations, :facebook, :string)
  end
end
