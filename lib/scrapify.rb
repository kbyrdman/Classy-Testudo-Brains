#!/usr/bin/env ruby
load File.absolute_path(File.join(__FILE__, "..", "..", "config", "environment.rb"))

require 'classy_testudo_brains'


results = UMD::Waitlist::Scraper.scrape
puts "\n\n**** RESULTS ****\n"
puts JSON.pretty_generate(results)

results.each do |department|
	department[:courses].each do |course|

		arr = Course.where(:course_id => course[:id])
		c = arr.first
=begin ## TODO
		if arr.count > 1
			c = arr.pop
			arr.each do |o|
				if o.last_update <=> c.last_update >= 0
					c.destroy
					c = o
				end
			end
		end
=end

		if c	
			c.course_id   =  course[:id]
			c.title       =  course[:title]
			c.credits     =  course[:credits]
			c.description =  course[:description]
			c.sections    =  course[:sections]
			c.last_update =  Time.now
		else
			c = Course.new(
				course_id:     course[:id],
				title:         course[:title],
				credits:       course[:credits],
				description:   course[:description],
				sections:      course[:sections],
				last_update:   Time.now
			)
		end

		c.save!
	end
end

#TODO: call class that will process the results and add to database