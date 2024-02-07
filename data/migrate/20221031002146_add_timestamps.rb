class AddTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :subjects, default: Time.now
    change_column_default :subjects, :created_at, nil
    change_column_default :subjects, :updated_at, nil

    add_timestamps :locations, default: Time.now
    change_column_default :locations, :created_at, nil
    change_column_default :locations, :updated_at, nil
  end
end
