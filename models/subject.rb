class Subject < ActiveRecord::Base
  scope(
    :short_name_starts_with,
    -> (prefix) do
      where("short_name LIKE :prefix", prefix: "#{prefix}%")
    end
  )
end
