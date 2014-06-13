require 'json'

module Classy
	module Testudo
		module Extractors
			def all_courses
				Models::Course.all.map{|c| JSON.parse(c.to_json)}
			end

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

			def find_courses(ids)
				ids.map{|id| find_course(id)}
			end

			def all_names
				ret = {}
				all_courses.collect do |course|
					ret[course["course_id"]] = course["title"]
				end
				ret
			end
		end
	end
end