#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'rack'
require 'json'
require 'tokyocabinet'
include TokyoCabinet

before do
  @hdb = HDB.new
  @hdb.open('sensordata.tch', HDB::OWRITER|HDB::OCREAT)
end

after do
  @hdb.close
end

get '/' do
  redirect './readme'
end

get '/keys' do
  keys = @hdb.keys.reverse[0...10000]
  keys.to_json
end

get '/count' do
  {"count", @hdb.rnum}.to_json
end

get '/last' do
  key = @hdb.keys.last
  {key, @hdb[key]}.to_json
end

get '/recent' do
  @hdb.keys.reverse[0...10].map{|k| {k, @hdb[k]} }.to_json
end

get '/recent/:num' do
  num = [params[:num].to_i, 1000].min
  @hdb.keys.reverse[0...num].map{|k| {k, @hdb[k]}}.to_json
end

get '/:tc_key' do
  key = params[:tc_key]
  {key, @hdb[key]}.to_json
end

post '/' do
  now = Time.now
  key = "#{now.to_i}_#{now.usec}"
  @hdb.put(key, params.to_json)
  {key, @hdb[key]}.to_json
end

delete '/:tc_key' do
key = params[:tc_key]
  v = @hdb[params[:tc_key]]
  @hdb.out(params[:tc_key])
  {key,v}.to_json
end
