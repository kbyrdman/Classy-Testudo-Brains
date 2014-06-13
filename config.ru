load 'config/environment.rb'
load 'lib/routes.rb'

run Rack::URLMap.new(
  "/classy-testudo" => Classy::Testudo::App.new
)