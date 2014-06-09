require 'core'

module UMD
	module Waitlist

		class Scraper

			def schedule_of_classes
				session.find(:xpath, "//a[text()='Schedule of Classes']")[:href]
			end


			def self.scrape(link="http://registrar.umd.edu/")
				session = Capybara::Session.new :poltergeist
				session.visit link
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
				departments.each do |url|
					session.visit url
					ret << Department.new(session).scrape
				end
				ret	
			end
		end


		class Department < Core

			def courses
				session.find(:xpath, "//div[@class='courses-container']").all(:css, "div")
			end

			def name
				session.find(:xpath, "//div[@class='course-prefix-info']").find(:xpath, ".//span[@class='course-prefix-abbr']").text
			end

			def scrape
				{ name => courses.map{|course| Class.new(course).scrape} }
			end
		end	


		class Class < Core

			def initialize(base)
				base.find(:xpath, ".//a[@class='toggle-sections-link']").click
				super(base)
			end
			
			def sections
				base.all(:css, "div[class='section']")
			end

			def course_id
				base.find(:css, "div[class='course-id']").text
			end

			def course_title
				base.find(:css, "span[class='course-title']").text
			end

			def course_credits
				base.find(:css, "span[class='course-min-credits']").text
			end

			def description
				base.find(:css, "div[class='approved-course-text']").text
			end
			
			def scrape
				{ 
					id: course_id,
					title: course_title,
					credits: course_credits,
					description: description,
					sections: sections.map{|s| Section.new(s).scrape}
				}
			end

			class Section < Core

				def section_number
					base.find(:css, "span[class='section-id']").text
				end

				def seats
					total = base.find(:css, "span[class='total-seats-count']").text
					open = base.find(:css, "span[class='open-seats-count']").text
					waitlist = base.find(:css, "span[class='waitlist-count']").text
					return { total: total, open: open, waitlist: waitlist }
				end

				def class_days
					base.find(:css, "span[class='section-days']").text
				end

				def start_time
					base.find(:css, "span[class='class-start-time']").text
				end

				def end_time
					base.find(:css, "span[class='class-end-time']").text
				end

				def instructor
					base.find(:css, "span[class='section-instructor']").text
				end

				def room_number
					base.find(:css, "span[class='class-room']").text
				end

				def building
					base.find(:css, "span[class='building-code']").text
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