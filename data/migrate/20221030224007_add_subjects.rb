class AddSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :short_name, null: false
      t.string :display_name, null: false
      t.string :url
      t.string :instagram
      t.string :facebook
      t.string :bandcamp
      t.string :type
      t.string :pronouns
    end

    add_index :subjects, :short_name, unique: true
  end
end
