require 'bundler/setup'

Bundler.require

Dir[__dir__ + '/app/**/*.rb'].each &method(:require)
puts "App loaded!"
