class SubjectTypeFix < ActiveRecord::Migration[7.0]
  def change
    rename_column :subjects, :type, :subject_type
  end
end
