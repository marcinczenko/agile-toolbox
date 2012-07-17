$LOAD_PATH << File.expand_path('../../../lib',__FILE__)

require 'capybara/cucumber'
require 'capybara-webkit'
require 'net/http'
require 'uri'
# require 'FileUtils'

Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

# Capybara.app_host = 'http://localhost:8000'

Capybara.run_server = false
