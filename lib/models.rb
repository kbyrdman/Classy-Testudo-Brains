require 'mongo_mapper'

module Classy
	module Testudo
		module Models
			class Course
				include MongoMapper::Document

				key :course_id, String,    :required => true
			  	key :title, String,   	   :default  => "N/A"
			  	key :credits, String
			  	key :description, String,  :default => "N/A"
			  	key :sections, Array,	   :default => []  		
			  	key :last_update, Time,    :default => lambda{Time.now}
			end
		end
	end
end


