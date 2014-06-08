require 'core'

module UMD
	module Waitlist

		class ScheduleOfClasses < Page

			# Initialize our base to the schedule of classes
			def initialize(link="http://registrar.umd.edu/")
				session = Capybara::Session.new :poltergeist
				session.visit link
				classes_url = session.find(:xpath, "//a[text()='Schedule of Classes']")[:href]
				super(classes_url)
			end

			def host
				"https://ntst.umd.edu/soc/"
			end

			def classes_lists
				base.xpath("//div[@id='course-prefixes-page']")
			end

			def left_list
				classes_lists.xpath("div[@id='left-course-prefix-column']")
			end

			def right_list
				classes_lists.xpath("div[@id='right-course-prefix-column']")
			end

			def scrape
				ret = []
				
				# Traversing every department
				left_list.xpath("div").each do |div|
					path = host + div.xpath("a")[:href]
					department_name = div.xpath(".//span").first.text
					ret << { department_name => Department.new(path).scrape }
				end

				right_list.xpath("div").each do |div|
					path = host + div.xpath("a")[:href]
					department_name = div.xpath(".//span").first.text
					ret << { department_name => Department.new(path).scrape }
				end
				ret	
			end
		end


		class Department < Page

			def courses
				course_container = base.xpath("//div[@class='courses-container']").first
				course_container.xpath("div")
			end

			def scrape
				courses.each do |course|

				end
			end
		end	

		class Class 

			attr_accessor :base
			def initialize(base)
				@base = base
			end

			def sections

			end

			def seats(section)

			end



			def scrape

			end
		end
	end
end