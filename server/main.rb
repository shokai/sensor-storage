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
  redirect '/readme'
end

get '/keys' do
  keys = Array.new
  @hdb.iterinit
  while key = @hdb.iternext do
    keys.push(key)
  end
  erb %{
    #{keys.to_json}
  }
end

get '/:tc_key' do
  erb %{
    #{@hdb.get(params[:tc_key])}
  }
end

post '/' do
  now = Time.now
  key = "#{now.to_i}_#{now.usec}"
  @hdb.put(key, params.to_json)
  erb %{
    #{key}
  }
end

delete '/:tc_key' do
  v = @hdb.get(params[:tc_key])
  @hdb.out(params[:tc_key])
  erb %{
    #{v}
  }
end
