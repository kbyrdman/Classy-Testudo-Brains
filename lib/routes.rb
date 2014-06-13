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

			get '/courses' do
        		content_type :json

        		return pretty_json(all_courses)
      		end

      		get '/courses/find?:courses' do
        		content_type :json

        		ids = params[:courses].split("&").map{|str| str.sub("id=", "")}

        		return pretty_json(find_courses(ids))
      		end

      		get '/courses/names' do
        		content_type :json

        		return pretty_json(all_names)
      		end

		end	
	end
end

