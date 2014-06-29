require 'classy_testudo_brains/core'
require 'holdon'

module Classy
	module Testudo

		## This will be in charge of initializing and running ScraperBots
		#  until the queue is empty, even when errors occur
		class ScraperBot
 
			attr_accessor :queue, :results, :root
			attr_reader :timeout
			
			def initialize(options={})
				@timeout = options.fetch(:timeout, 60)
				@queue = options.fetch(:queue, [])
				@results = []
				@root = options.fetch(:root)
			end

			def self.create(options={})
				link = options.fetch(:link, "https://ntst.umd.edu/soc/") 

				root = Nokogiri::HTML(%x{curl "#{link}"})
				
				soc = ScheduleOfClasses.new root
				q = soc.departments

				max = options.fetch(:max, q.count)
				q.slice!(max...q.count)

				options.merge!({queue: q, root: root})
				return self.new(options)
			end


			def scrape

				start = Time.now
				while !queue.empty?
					unless (Time.now - start) <= timeout.minutes
						puts "Scrape took longer that #{timeout} minutes"
						break
					end

					begin
						department = queue[0]
						session.visit department
						department_page = Department.new(session)
						results << department_page.scrape
						queue.delete_at(0)

					rescue SystemExit, Interrupt
						return results

					rescue Exception => ex
						puts "Caught Exception!  ~>  #{ex.message}"
						puts "Continuing scrape: queue - #{@queue}"
						session = Capybara::Session.new :poltergeist
					end
				end
				return results
			end
		end


		class ScheduleOfClasses < DOM

			attr_reader :domain
			def initialize(root, domain)
				@domain = domain
				super(root)
			end

			def department_lists
				root.xpath("//div[@id='course-prefixes-page']")
			end

			def left_list
				department_lists.xpath("div[@id='left-course-prefix-column']")
			end

			def right_list
				department_lists.xpath("div[@id='right-course-prefix-column']")
			end

			def departments
				left_list.xpath("./div").map{|div| domain + div.xpath("./a").attribute("href").text} +
				right_list.xpath("./div").map{|div| domain + div.xpath("./a").attribute("href").text}
			end

		end


		class Department < DOM

			def courses
				session.find(:xpath, "//div[@class='courses-container']").all(:xpath, "./div") rescue []
			end

			def abrv
				session.find(:xpath, "//div[@class='course-prefix-info']").find(:xpath, ".//span[@class='course-prefix-abbr']").text rescue "N/A"
			end

			def name
				session.find(:xpath, "//span[@class='course-prefix-name']").text rescue "N/A"
			end

			def scrape
				{ 
					department_abrv: abrv,
					department_name: name,
					courses: courses.map{|course| puts "scraping #{course[:id]}"; c = Course.new(course); c.scrape}
				}
			end
		end	


		class Course < DOM

			def initialize(base)
				domain = "https://ntst.umd.edu"
				course_link = domain + base.first(:css, "a[class='toggle-sections-link']")[:href]
				course_id = base[:id]
				puts "visiting #{course_link}"

				root = Nokogiri::XML(%x{curl "#{course_link}"})
				super(root.xpath("//div[@id='#{course_id}']"))
=begin
				if 
					base.first(:css, "a[class='toggle-sections-link']").click
					## TODO: Make this better
					HoldOn.until(timeout: 25) do 
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
=end
			end
			
			def sections
				root.xpath("div[class='section']") 
			end

			def course_id
				root.first(:css, "div[class='course-id']").text rescue "N/A"
			end

			def course_title
				root.first(:css, "span[class='course-title']").text rescue "N/A"
			end

			def course_credits
				root.first(:css, "span[class='course-min-credits']").text rescue "N/A"
			end

			def description
				ret = ""
				root.all(:css, "div[class='approved-course-text']").each{|des| ret << des.text + "\n\n"}
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

			class Section < DOM

				def section_number
					root.find(:css, "span[class='section-id']").text rescue "N/A"
				end

				def seats
					total = open = waitlist = "N/A"
					if root.first(:css, "span[class='total-seats-count']")
						total = root.first(:css, "span[class='total-seats-count']").text
					end
					if root.first(:css, "span[class='open-seats-count']")
						open = root.first(:css, "span[class='open-seats-count']").text
					end
					if root.first(:css, "span[class='waitlist-count']")
						waitlist = root.first(:css, "span[class='waitlist-count']").text
					end
					return { total: total, open: open, waitlist: waitlist }
				end

				def class_days
					root.find(:css, "span[class='section-days']").text rescue "N/A" 
				end

				def start_time
					root.find(:css, "span[class='class-start-time']").text rescue "N/A"
				end

				def end_time
					root.find(:css, "span[class='class-end-time']").text rescue "N/A"
				end

				def instructor
					root.find(:css, "span[class='section-instructor']").text rescue "N/A"
				end

				def room_number
					root.find(:css, "span[class='class-room']").text rescue "N/A"
				end

				def building
					root.find(:css, "span[class='building-code']").text rescue "N/A"
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