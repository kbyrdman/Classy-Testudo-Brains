require 'capybara/poltergeist'
require 'nokogiri'
require 'open-uri'


module UMD
	module Waitlist
		class Core

			attr_accessor :base
			def initialize(base)
				@base = base
			end

			def session
		        if base.is_a? Capybara::Session
		          return base
		        else
		          return base.session
		        end
		    end

		end
	end
end