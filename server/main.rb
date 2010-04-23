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
  erb %{
    <h1>sensor-storage API</h1>
    <ul>
      <li>get
        <ul>
          <li><a href="/keys">list of keys</a></li>
          <li>/(key) get value</li>
        </ul>
      </li>
      <li>post
        <ul>
          <li>/ post value</li>
        </ul>
      </li>
      <li>delete
        <ul>
          <li>/(key) delete value</li>
        </ul>
      </li>
    </ul>
  }
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
