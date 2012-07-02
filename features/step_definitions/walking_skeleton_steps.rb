def wait_for_google_mock_to_start(failure_message)
  begin
    Capybara.default_wait_time = 7
    wait_until { get_from_uri("https://quantumagiletoolbox-dev.appspot.com/ready")  }
    yield if block_given?
  rescue Capybara::TimeoutError
    raise failure_message
  end
end

def get_from_uri(uri)
  uri = URI.parse("https://quantumagiletoolbox-dev.appspot.com/ready")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  
  if response.is_a?(Net::HTTPOK)
    true
  else
    false
  end
  # puts response.body
  #   puts response.code
end


Given /^Google App Engine Server Mock with (\d+) items is started$/ do |arg1|
  @google_mock = Runners::SimpleRunner.new("sudo #{File.join(ENV['WORKON_HOME'],'GoogleAppEngineWebAppMock/bin/python')} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n 5")
  @google_mock.start()
  wait_for_google_mock_to_start("GoogleAppEngine Mock does not appear to be operational.")
end

After do
  # We have use a separate runner to kill the app becuase we running as the root user.
  killer = Runners::SimpleRunner.new("sudo kill -s INT #{@google_mock.pid()}")
  killer.start()
  killer.wait()
end

Then /^I should be able to retrieve these (\d+) items using my iPhone App \(Walking_Skeleton_suite\.js\)$/ do |arg1|
  
end



# Before do
#   @runner = Runners::SimpleRunner.new('/usr/local/bin/dev_appserver.py --clear_datastore -p 8000 .')
#   @runner.start()
#   sleep(5)
# end
# 
# After do
#   @runner.notify("INT")
# end
# 
# When /^I visit "(.*?)"$/ do |path|
#   visit(path)
#   page.should have_content("Wow ! Here you can create a new item. Isn't it great?")
# end
# 
# When /^I set "(.*?)" as new item on the web form$/ do |new_item|
#   fill_in('content', :with => new_item)
# end
# 
# When /^I click on "(.*?)"$/ do |button_name|
#   click_button('Add')
# end
# 
# Then /^I should be redirected to "(.*?)" and see "(.*?)" on the list of items$/ do |expected_path,expected_item|
#   current_path.should == expected_path
#   page.should have_content(expected_item)
# end
# 
# When /^I post a new text item "(.*?)" to the server with "(.*?)"$/ do |text_item,url|
#   @text_item = text_item
# end
# 
# Then /^I should be able to retrieve the same item with the GET request "(.*?)"$/ do |url|
#   visit(url)
#   page.should have_content(text_item)
# end
