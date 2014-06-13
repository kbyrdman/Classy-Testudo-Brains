#!/usr/bin/env ruby
load File.absolute_path(File.join(__FILE__, "..", "..", "config", "environment.rb"))

require 'classy_testudo_brains'


results = Classy::Testudo::Scraper.scrape
puts "\n\n**** RESULTS ****\n"
puts JSON.pretty_generate(results)

include Classy::Testudo
results.each do |department|
	department[:courses].each do |course|


		arr = Models::Course.where(:course_id => course[:id]).sort(:last_update.desc).all

		unless arr.empty?
			c = arr.delete_at(0)
			arr.collect{|crs| crs.destroy}
		end

		if c	
			c.course_id   =  course[:id]
			c.title       =  course[:title]
			c.credits     =  course[:credits]
			c.description =  course[:description]
			c.sections    =  course[:sections]
			c.last_update =  Time.now
		else
			c = Models::Course.new(
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
