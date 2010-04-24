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
  keys = Array.new
  @hdb.iterinit
  while key = @hdb.iternext do
    keys.push(key)
    break if keys.size >= 10000
  end
  erb %{
    #{keys.to_json}
  }
end

get '/count' do
  result = {"count", @hdb.rnum}
  erb %{
    #{result.to_json}
  }
end

get '/last' do
  key = @hdb.keys.last
  result = {key, @hdb[key]}
  erb %{
    #{result.to_json}
  }
end

get '/recent' do
  result = @hdb.keys.reverse[0...10].map{|k| {k, @hdb[k]} }
  erb %{
    #{result.to_json}
  }
end

get '/recent/:num' do
  result = @hdb.keys.reverse[0...params[:num].to_i].map{|k| {k, @hdb[k]}}
  erb %{
    #{result.to_json}
  }
end

get '/:tc_key' do
  key = params[:tc_key]
  result = {key, @hdb[key]}
  erb %{
    #{result.to_json}
  }
end

post '/' do
  now = Time.now
  key = "#{now.to_i}_#{now.usec}"
  @hdb.put(key, params.to_json)
  erb %{
    #{{key, @hdb[key]}.to_json}
  }
end

delete '/:tc_key' do
key = params[:tc_key]
  v = @hdb[params[:tc_key]]
  @hdb.out(params[:tc_key])
  erb %{
    #{{key,v}.to_json}
  }
end
