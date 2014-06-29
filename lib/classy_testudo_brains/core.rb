require 'capybara/poltergeist'
require 'nokogiri'
require 'open-uri'


module Classy
	module Testudo

		## This represents a capybara session
		class Page

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


		## This represents a nokogiri dom instance
		class DOM
			attr_accessor :root
			def initialize(root)
				@root = root
			end

			def request(url)
				return Nokogiri::XML(%x{curl "#{url}"})
			end

			def sub(text)
				text.gsub!(/\r/, "")
				text.gsub!(/\t/, "")
				text.gsub!(/\n/, "")
				return text
			end
		end
	end
end