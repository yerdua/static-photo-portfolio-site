require "bundler/setup"

Bundler.require
require "active_record"
require "yaml"

namespace(:db) do
  db_config = YAML::load(File.open("config/database.yml"))

  desc("Create the database")
  task(:create) do
    ActiveRecord::Base.establish_connection(db_config)
    puts("Database created")
  end

  desc("Migrate the database")
  task(:migrate => :create) do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::MigrationContext.new("data/migrate/", ActiveRecord::SchemaMigration).migrate
    Rake::Task["db:schema"].invoke
    puts("Database migrated")
  end

  desc("Create a data/schema.rb file")
  task(:schema) do
    ActiveRecord::Base.establish_connection(db_config)
    require "active_record/schema_dumper"

    filename = "data/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end

    puts("Schema dumped")
  end
end

namespace(:g) do
  desc("Generate migration")
  task(:migration) do
    name = ARGV[1] || raise("Specify name: rake g:migration migration_name")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../data/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, "w") do |file|
      file.write(
        <<~EOF
          class #{migration_class} < ActiveRecord::Migration[7.0]
            def change
            end
          end
        EOF
      )
    end

    puts("Migration #{path} created")
    # needed stop other tasks
    abort
  end
end
