APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")).freeze 
$LOAD_PATH << File.join(APP_ROOT, 'lib') unless $LOAD_PATH.include?(File.join(APP_ROOT, 'lib'))

require 'capybara/poltergeist'
require 'classy_testudo_brains'