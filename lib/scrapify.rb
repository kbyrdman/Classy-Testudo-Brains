#!/usr/bin/env ruby
load File.absolute_path(File.join(__FILE__, "..", "..", "config", "environment.rb"))

require 'classy_testudo_brains'

options = {}
if ARGV.any? and (ARGV.count % 2 == 0)
	if ARGV.include? "-M"
		max = ARGV[ARGV.index("-M") + 1].to_i
		options[:max] = max
	elsif ARGV.include? "-t"
		timeout = ARGV[ARGV.index("-t") + 1].to_i
		puts "setting timeout to #{timeout} minutes"
		options[:timeout] = timeout
	elsif ARGV.include? "-L"
		link = ARGV[ARGV.index("-L") + 1]
		options[:link] = link
	end
elsif ARGV.count == 0
	# do nothing, just run
else
	$stderr.puts "Usage: #{$0} -M [Max] -L [Link] -t [timeout]"
	exit 1 
end


puts "starting: #{Time.now} \n\n"
bot = Classy::Testudo::ScraperBot.create(options)
results = bot.scrape
puts "ending: #{Time.now} \n\n"

count = 0
results.collect{|dep| count = count + dep[:courses].count}
puts "#{count} classes found"

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

		puts "saving course #{c.course_id}"

		begin
			c.save!
		rescue Exception => ex
			puts "\n\n\nSomething happened while saving!"
			puts ex.message
			ex.backtrace.each{|s| puts s}
			puts "\n\n\n"
		end
	end
end
