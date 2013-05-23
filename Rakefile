#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Cachepig::Application.load_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
namespace :spec do
  [:requests, :models, :controllers, :views, :helpers, :lib, :routing].each do |sub|
    desc "Run the code examples in spec/#{sub}"
    RSpec::Core::RakeTask.new(sub) do |t|
      t.pattern = "./spec/#{sub}/**/*_spec.rb"
    end
  end
end

