require 'classy_testudo_brains/core'
require 'holdon'

module UMD
	module Waitlist

		class Scraper

			def self.scrape(link="http://registrar.umd.edu/")
				session = Capybara::Session.new :poltergeist
				puts "Visiting #{link}"
				session.visit link
				schedule_of_classes = session.find(:xpath, "//a[text()='Schedule of Classes']")[:href]
				puts "Visiting schedule of classes #{schedule_of_classes}"
				session.visit schedule_of_classes
				page = ScheduleOfClasses.new session
				return page.scrape
			end
		end


		class ScheduleOfClasses < Core

			def department_lists
				session.find(:xpath, "//div[@id='course-prefixes-page']")
			end

			def left_list
				department_lists.find(:xpath, "div[@id='left-course-prefix-column']")
			end

			def right_list
				department_lists.find(:xpath, "div[@id='right-course-prefix-column']")
			end

			def departments
				left_list.all(:xpath, "./div").map{|div| session.current_url + div.find(:xpath, "./a")[:href]} +
				right_list.all(:xpath, "./div").map{|div| session.current_url + div.find(:xpath, "./a")[:href]}
			end


			def scrape
				ret = []
				#puts departments
				departments.each do |url|
					puts url
					session.visit url
					page = Department.new(session)
					ret << page.scrape
				end
				ret	
			end
		end


		class Department < Core

			def courses
				session.find(:xpath, "//div[@class='courses-container']").all(:xpath, "./div")
			end

			def abrv
				session.find(:xpath, "//div[@class='course-prefix-info']").find(:xpath, ".//span[@class='course-prefix-abbr']").text
			end

			def name
				session.find(:xpath, "//span[@class='course-prefix-name']").text
			end

			def scrape
				{ 
					department_abrv: abrv,
					department_name: name,
					courses: courses.map{|course| puts "scraping #{course[:id]}"; c = Course.new(course); c.scrape} 
				}
			end
		end	


		class Course < Core

			def initialize(base)
				if base.first(:css, "a[class='toggle-sections-link']")
					base.first(:css, "a[class='toggle-sections-link']").click
					HoldOn.until(timeout: 10) do 
						if base.first(:css, "div[class='sections-container']")
							if !base.first(:css, "div[class='sections-container']")[:style].include?("display: none;") 
								true
							else
								false
							end
						else 
							false
						end
					end
				end
				super(base)
			end
			
			def sections
				base.all(:css, "div[class='section']") 
			end

			def course_id
				base.first(:css, "div[class='course-id']").text rescue "N/A"
			end

			def course_title
				base.first(:css, "span[class='course-title']").text rescue "N/A"
			end

			def course_credits
				base.first(:css, "span[class='course-min-credits']").text rescue "N/A"
			end

			def description
				ret = ""
				base.all(:css, "div[class='approved-course-text']").each{|des| ret << des.text + "\n\n"}
				if ret == ""
					ret = "N/A"
				end
				ret
			end
			
			def scrape
				{ 
					id: course_id,
					title: course_title,
					credits: course_credits,
					description: description,
					sections: sections.map{|s| sec = Section.new(s); sec.scrape}
				}
			end

			class Section < Core

				def section_number
					base.find(:css, "span[class='section-id']").text rescue "N/A"
				end

				def seats
					total = open = waitlist = "N/A"
					if base.first(:css, "span[class='total-seats-count']")
						total = base.first(:css, "span[class='total-seats-count']").text
					end
					if base.first(:css, "span[class='open-seats-count']")
						open = base.first(:css, "span[class='open-seats-count']").text
					end
					if base.first(:css, "span[class='waitlist-count']")
						waitlist = base.first(:css, "span[class='waitlist-count']").text
					end
					return { total: total, open: open, waitlist: waitlist }
				end

				def class_days
					base.find(:css, "span[class='section-days']").text rescue "N/A" 
				end

				def start_time
					base.find(:css, "span[class='class-start-time']").text rescue "N/A"
				end

				def end_time
					base.find(:css, "span[class='class-end-time']").text rescue "N/A"
				end

				def instructor
					base.find(:css, "span[class='section-instructor']").text rescue "N/A"
				end

				def room_number
					base.find(:css, "span[class='class-room']").text rescue "N/A"
				end

				def building
					base.find(:css, "span[class='building-code']").text rescue "N/A"
				end

				def scrape
					{
						number: section_number,
						seats: seats,
						days: class_days,
						start_time: start_time,
						end_time: end_time,
						instructor: instructor,
						room_number: room_number,
						building: building
					}
				end
			end
		end
	end
end