#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'rack'
require 'json'
require 'tokyocabinet'
include TokyoCabinet

@@dbdir = 'db'

def db_open(dbname='/')
  dbname = dbname.to_s.gsub(/\//, '_')
  @hdb = HDB.new
  Dir.mkdir(@@dbdir) if !File.exists?(@@dbdir)
  @hdb.open("#{@@dbdir}/#{dbname}.tch", HDB::OWRITER|HDB::OCREAT)  
end

after do
  @hdb.close if @hdb
end

get '*/' do
  path = "../" * params[:splat].first.count('/')
  redirect "#{path}./readme"
end

get '*/keys' do
  db_open(params[:splat])
  @hdb.keys.reverse[0...10000].to_json
end

get '*/count' do
  db_open(params[:splat])
  {"count", @hdb.rnum}.to_json
end

get '*/last' do
  db_open(params[:splat])
  key = @hdb.keys.last
  {key, @hdb[key]}.to_json
end

get '*/recent' do
  db_open(params[:splat])
  @hdb.keys.reverse[0...10].map{|k| {k, @hdb[k]} }.to_json
end

get '*/recent/:num' do
  db_open(params[:splat])
  num = [params[:num].to_i, 1000].min
  @hdb.keys.reverse[0...num].map{|k| {k, @hdb[k]}}.to_json
end

get '*/:tc_key' do
  db_open(params[:splat])
  key = params[:tc_key]
  {key, @hdb[key]}.to_json
end

post '*/' do
  db_open(params[:splat])
  now = Time.now
  key = "#{now.to_i}_#{now.usec}"
  @hdb.put(key, params.to_json)
  {key, @hdb[key]}.to_json
end

delete '*/:tc_key' do
key = params[:tc_key]
  v = @hdb[params[:tc_key]]
  @hdb.out(params[:tc_key])
  {key,v}.to_json
end

