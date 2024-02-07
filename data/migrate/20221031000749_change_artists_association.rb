class ChangeArtistsAssociation < ActiveRecord::Migration[7.0]
  def change
    create_table :artwork_to_artists do |t|
      t.belongs_to :artist, foreign_key: { to_table: :subjects }
      t.belongs_to :piece, foreign_key: { to_table: :subjects }

      t.timestamps
    end
  end
end
