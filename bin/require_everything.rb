#!/usr/bin/env ruby

require "bundler/setup"

Bundler.require

require "irb"
require "irb/completion"

require "yaml"

require "active_record"
require "sqlite3"

require "zip"

ActiveRecord::Base.establish_connection(YAML::load(File.open("config/database.yml")))

require "./config/constants.rb"

require "./models/helpers.rb"

include(Helpers)

# Require models in order
require "./models/subject.rb"
require "./models/location.rb"
require "./models/page.rb"
require "./models/about.rb"
require "./models/photo.rb"
require "./models/base_album.rb"
require "./models/archive_album.rb"
require "./models/portfolio_album.rb"
require "./models/portfolio.rb"
require "./models/preview_album.rb"
require "./models/origin_album.rb"
require "./models/origin_photo.rb"
require "./models/archive.rb"
require "./models/home.rb"
require "./models/portfolio.rb"
require "./models/blog_post.rb"
require "./models/blog.rb"
require "./models/insta_links.rb"
require "./models/error_page.rb"
require "./models/site.rb"
require "./models/download.rb"
require "./models/rss_feed.rb"
