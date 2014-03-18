#$LOAD_PATH << File.expand_path('../',__FILE__)
#$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'capybara/cucumber'
require 'capybara-webkit'
require 'net/http'
require 'uri'

Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

if ENV['RUN_ON_GAE']
  Capybara.app_host = 'https://ep-demo.appspot.com'
else
  Capybara.app_host = 'http://ep-demo.com:9001'
end

Capybara.run_server = false
