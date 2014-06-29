require 'classy_testudo_brains/core'
require 'holdon'

module Classy
	module Testudo

		## This will be in charge of initializing and running ScraperBots
		#  until the queue is empty, even when errors occur
		class ScraperBot
 
			attr_accessor :queue, :results
			attr_reader :timeout
			
			def initialize(options={})
				@timeout = options.fetch(:timeout, 60)
				@queue = options.fetch(:queue, [])
				@results = []
			end

			def self.create(options={})
				link = options.fetch(:link, "https://ntst.umd.edu/soc/") 

				root = Nokogiri::HTML(%x{curl -s "#{link}"})
				
				soc = ScheduleOfClasses.new root, link
				q = soc.departments

				max = options.fetch(:max, q.count)
				q.slice!(max...q.count)

				options.merge!({queue: q})
				return self.new(options)
			end


			def scrape

				start = Time.now
				while !queue.empty?
					unless (Time.now - start) <= timeout.minutes
						puts "Scrape took longer that #{timeout} minutes"
						return results
					end

					begin
						department = queue[0]
						root = Nokogiri::HTML(%x{curl -s "#{department}"})
						department_page = Department.new(root)
						results << department_page.scrape
						queue.delete_at(0)

					rescue SystemExit, Interrupt
						return results

					rescue Exception => ex
						puts "Caught Exception!  ~>  #{ex.message}"
						ex.backtrace.each{|s| puts s}

						if ex.message.include? "abort then interrupt!"
							return results
						else
							puts "Continuing scrape: queue - #{@queue}"
						end
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
				root.xpath(".//div[@id='course-prefixes-page']")
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
				root.xpath(".//div[@class='courses-container']").xpath("./div") rescue []
			end

			def abrv
				root.xpath(".//div[@class='course-prefix-info']").xpath(".//span[@class='course-prefix-abbr']").text rescue "N/A"
			end

			def name
				root.xpath(".//span[@class='course-prefix-name']").text rescue "N/A"
			end

			def scrape
				{ 
					department_abrv: sub(abrv),
					department_name: sub(name),
					courses: courses.map{|course| puts "scraping #{course[:id]}"; c = Course.new(course); c.scrape}
				}
			end
		end	


		class Course < DOM

			def initialize(base)
				domain = "https://ntst.umd.edu"

				if !base.xpath(".//a[@class='toggle-sections-link']").empty?
					course_link = domain + base.xpath(".//a[@class='toggle-sections-link']").attribute("href").text
					course_id = base.attribute("id").text
					puts "visiting #{course_link}"

					dom = Nokogiri::HTML(%x{curl -s "#{course_link}"})
					root = dom.xpath(".//div[@id='#{course_id}']").first
				else
					root = base
				end
				
				super(root)
			end
			
			def sections
				root.xpath(".//div[@class='section']") 
			end

			def course_id
				root.xpath(".//div[@class='course-id']").text rescue "N/A"
			end

			def course_title
				root.xpath(".//span[@class='course-title']").text rescue "N/A"
			end

			def course_credits
				root.xpath(".//span[@class='course-min-credits']").text rescue "N/A"
			end

			def description
				ret = ""
				root.xpath(".//div[@class='approved-course-text']").each{|des| ret << des.text + "\n\n"}
				if ret == ""
					ret = "N/A"
				end
				ret
			end
			
			def scrape
				{ 
					id: sub(course_id),
					title: sub(course_title),
					credits: sub(course_credits),
					description: description,
					sections: sections.map{|s| sec = Section.new(s); sec.scrape}
				}
			end

			class Section < DOM

				def section_number
					root.xpath(".//span[@class='section-id']").text rescue "N/A"
				end

				def seats
					total = open = waitlist = "N/A"
					if root.xpath(".//span[@class='total-seats-count']")
						total = root.xpath(".//span[@class='total-seats-count']").text
					end
					if root.xpath(".//span[@class='open-seats-count']")
						open = root.xpath(".//span[@class='open-seats-count']").text
					end
					if root.xpath(".//span[@class='waitlist-count']")
						waitlist = root.xpath(".//span[@class='waitlist-count']").text
					end
					return { total: sub(total), open: sub(open), waitlist: sub(waitlist) }
				end

				def class_days
					root.xpath(".//span[@class='section-days']").text rescue "N/A" 
				end

				def start_time
					root.xpath(".//span[@class='class-start-time']").text rescue "N/A"
				end

				def end_time
					root.xpath(".//span[@class='class-end-time']").text rescue "N/A"
				end

				def instructor
					root.xpath(".//span[@class='section-instructor']").text rescue "N/A"
				end

				def room_number
					root.xpath(".//span[@class='class-room']").text rescue "N/A"
				end

				def building
					root.xpath(".//span[@class='building-code']").text rescue "N/A"
				end

				def scrape
					{
						number: sub(section_number),
						seats: seats,
						days: sub(class_days),
						start_time: sub(start_time),
						end_time: sub(end_time),
						instructor: sub(instructor),
						room_number: sub(room_number),
						building: sub(building)
					}
				end
			end
		end
	end
end