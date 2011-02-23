require 'rubygems'
require 'bundler/setup'

require 'dm-core'
require 'dm-migrations'

dir = File.expand_path(File.dirname(__FILE__))

DataMapper.setup(:default, "sqlite3://#{dir}/jabberwocky.db")

require "#{dir}/../lib/subscriber"

AppConfig = YAML.load_file("#{dir}/jabberwocky.yml")

DataMapper.auto_upgrade!
DataMapper.finalize
