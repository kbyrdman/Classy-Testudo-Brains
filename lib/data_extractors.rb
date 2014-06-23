require 'json'

module Classy
	module Testudo
		module Extractors

			## Finds all Courses that exist in the database
			def all_courses
				Models::Course.all.map{|c| JSON.parse(c.to_json)}
			end

			## Finds a course with the given course id
			def find_course(course_id)
				arr = Models::Course.where(:course_id => course_id).sort(:last_update.desc).all

				if arr.empty?
					return {}
				else
					c = arr.delete_at(0)
					arr.collect{|crs| crs.destroy}
					return JSON.parse(c.to_json)
				end
			end

			## Returns an array with all courses corresponding to the given array of ids
			def find_courses(ids)
				ids.map{|id| find_course(id)}
			end

			## 
			def all_full_names
				ret = {}
				all_courses.collect do |course|
					ret[course["course_id"]] = course["title"]
				end
				ret
			end

			def all_ids
				all_courses.map{|course| course["course_id"]}
			end


			def all_sections
				ret = {}
				all_courses.each do |c|
					ret[c["course_id"]] = c["sections"]
				end
				ret
			end

			def find_section(id)
				{ id => all_sections.fetch("#{id}", []) }
			end

			def find_sections(ids)
				ret = {}
				all_sections.each do |id, sec|
					ret[id] = sec if ids.include?(id)
				end
				ret
			end
		end
	end
end