#!/usr/bin/env ruby
load File.absolute_path(File.join(__FILE__, "..", "..", "config", "environment.rb"))

require 'classy_testudo_brains'


results = UMD::Waitlist::Scraper.scrape
puts JSON.pretty_generate(results)

#TODO: call class that will process the results and add to database