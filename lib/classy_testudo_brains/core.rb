require 'capybara/poltergeist'
require 'nokogiri'
require 'open-uri'


module UMD
	module Waitlist
		class Page

			attr_accessor :base
			def initialize(link)
				uri = URI.parse(link)
				response = Net::HTTP.get_response(uri)
				@base = Nokogiri::HTML(response.body)
			end
		end
	end
end