class AddLocationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :short_name, null: false
      t.string :display_name, null: false
      t.string :url
      t.string :city
      t.string :state
      t.string :country
    end
  end
end
