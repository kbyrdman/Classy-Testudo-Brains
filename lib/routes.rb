require 'sinatra/base'
require 'json'
require 'data_extractors'
require 'models'

module Classy
	module Testudo

		class App < Sinatra::Base

			include Classy::Testudo::Extractors

			def pretty_json(data)
				JSON.pretty_generate(data)
			end

			get '/courses/all' do
    		content_type :json

    		return pretty_json(all_courses)
  		end

      # example payload: [course_id1, course_id2, course_id3]
  		post '/courses/find' do
    		content_type :json

        begin 
          ids = JSON.parse(request.body.read)
        rescue Exception => ex
          return "Bad Request! -- Not Valid JSON: #{ex.message}"
        end

    		return pretty_json(find_courses(ids))
  		end

      get '/courses/range/:range' do
        content_type :json

        range = params[:range].gsub("range=", "")
        from = range.split("-")[0]
        to = range.split("-")[1]

        return pretty_json(find_range(from, to))
      end

      get '/courses/find/:id' do
        content_type :json

        id = params[:id].split("=")[1]
        return pretty_json(find_course(id))
      end

  		get '/courses/names' do
    		content_type :json

    		return pretty_json(all_full_names)
  		end

      get '/courses/ids' do
        content_type :json

        return pretty_json(all_ids)
      end


      get '/sections/all' do
        content_type :json

        return pretty_json(all_sections)
      end

      get '/sections/find/:id' do
        content_type :json

        id = params[:id].split("=")[1]
        return pretty_json(find_section(id))
      end


      # example payload: [course_id1, course_id2, course_id3]
      post '/sections/find' do
        content_type :json

        begin 
          ids = JSON.parse(request.body.read)
        rescue Exception => ex
          return "Bad Request! -- Not Valid JSON: #{ex.message}"
        end

        return pretty_json(find_sections(ids))
      end

		end	
	end
end

