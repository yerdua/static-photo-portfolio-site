class AddSubjLongName < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :long_name, :string
  end
end
