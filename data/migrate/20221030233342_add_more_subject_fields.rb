class AddMoreSubjectFields < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :info, :string
    add_column :subjects, :patreon, :string
    add_reference :subjects, :artist, foreign_key: { to_table: :subjects }
  end
end
