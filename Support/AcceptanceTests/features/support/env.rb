$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'capybara/cucumber'
require 'capybara-webkit'
require 'net/http'
require 'uri'
# require 'FileUtils'

Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

if ENV['RUN_ON_GAE']
  Capybara.app_host = 'https://ep-qat-dev-1.appspot.com'
else
  Capybara.app_host = 'http://192.168.1.33:9001'
end

Capybara.run_server = false
