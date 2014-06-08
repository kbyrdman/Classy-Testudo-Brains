Gem::Specification.new do |s|
  s.name        = 'classy_testudo_brains'
  s.version     = '0.0.1'
  s.date        = '2014-06-08'
  s.summary     = "Scraper for UMD waitlists"
  s.description = "Scraper for UMD waitlists"
  s.authors     = ["Kyle Byrd"]
  s.email       = 'kylealanbyrd@gmail.com'
  s.files       = Dir["lib/**/*.rb"] + Dir["data/**/*"]

  s.add_dependency "capybara", "~> 1.1.2"
  s.add_dependency "poltergeist", "~> 1.0.3"
end