require 'rubygems'
require 'bundler'
require 'active_record'
require 'nokogiri'
require 'pp'
require 'csv'
require 'zlib'
require 'oauth'
require 'cgi'
require 'uri'
require 'active_support/core_ext'
#require "zip/zip"
require 'open-uri'
require 'mechanize'
require 'twitter'
require 'socket'


dbname = 'twitter'

host = 'localhost'
user = 'root'
pass = ''

# DB接続処理
ActiveRecord::Base.establish_connection(
        :adapter  => 'mysql2',
        :charset => 'utf8mb4',
        :encoding => 'utf8mb4',
        :collation => 'utf8mb4_general_ci',
        :database => dbname,
        :host     => host,
        :username => user,
        :password => pass
)

# DBのタイムゾーン設定
Time.zone_default =  Time.find_zone! 'Tokyo' # config.time_zone
ActiveRecord::Base.default_timezone = :local # config.active_record.default_timezone

class Tweet < ActiveRecord::Base
end

class Account < ActiveRecord::Base
end
