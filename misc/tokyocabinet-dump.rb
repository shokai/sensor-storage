#!/usr/bin/ruby
require 'rubygems'
require 'tokyocabinet'
include TokyoCabinet

exit if ARGV.size < 1
dbfile = ARGV.shift

hdb = HDB.new
hdb.open(dbfile, HDB::OWRITER)

keys = Array.new
hdb.iterinit
while key = hdb.iternext do
  keys.push(key)
end

keys.each{|k|
  puts "#{k} => #{hdb[k]}"

}

hdb.close
