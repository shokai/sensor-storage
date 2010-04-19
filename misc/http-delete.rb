#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'ArgsParser'

parser = ArgsParser.parser
parser.bind(:host, :h, "hostname")
parser.comment(:port, "port")
parser.bind(:path, :p, "path")
first, params = parser.parse(ARGV)

if !parser.has_params([:host, :path])
  puts parser.help
  puts 'e.g. ruby http-delete.rb -h localhost -p /path/to/app'
  exit 1
end

params[:port] = 80 if !params[:port]
Net::HTTP.start(params[:host], params[:port].to_i) {|http|
  response = http.delete(params[:path])
  puts response.body
}
