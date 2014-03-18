
Before do
  application_sandbox = Helpers::PathFinder.find(:ApplicationSandbox)
  if application_sandbox
    puts "Cleaning #{application_sandbox}/Library/Application Support"
    FileUtils.rm_rf "#{application_sandbox}/Library/Application Support"
  end
end

if ENV['RUN_ON_GAE_DEVELOPMENT'] or ENV['RUN_ON_GAE']
  def get_http_object_for(relative_url)
    uri = URI.parse("#{Capybara.app_host}/#{relative_url}")
    http = Net::HTTP.new(uri.host, uri.port)
    if ENV['RUN_ON_GAE']
      http.use_ssl = true
    end
    {:http => http, :uri => uri}
  end

  def get_from(relative_url)
    locator = get_http_object_for(relative_url)
    request = Net::HTTP::Get.new(locator[:uri].request_uri)
    locator[:http].request(request)
  end

  Before do
    puts 'Purging datastore...'
    response = get_from('questions_configure?clear=1&only_accepted=False')

    expect(response.is_a?(Net::HTTPOK)).to be true
    expect(response.code).to eq('200')

    expect(response.body).to eq('OK')
  end

  Given /^Google App Engine Server Mock with (\d+) items (?:and (\d+) seconds delay )?is started$/ do |number_of_items,delay|
    if delay
      response = get_from("questions_configure?add=#{number_of_items}&delay=#{delay}")
    else
      response = get_from("questions_configure?add=#{number_of_items}")
    end

    expect(response.is_a?(Net::HTTPOK)).to be true
    expect(response.code).to eq('200')

    expect(response.body).to eq('OK')
  end
else
  After do
    @google_mock.stop
  end

  Given /^Google App Engine Server Mock with (\d+) items (?:and (\d+) seconds delay )?is started$/ do |number_of_items,delay|
    @google_mock = Runners::GoogleAppEngineMockRunner.new({:virtualenv=>'GoogleAppEngineAppMock',:number_of_items=>number_of_items, :delay=>delay})
    @google_mock.set_verbose(true)
    @google_mock.start
  end
end

Then /^RUN: Feature: "(.*?)" Scenario:"(.*?)"(?: \(timeout:(\d+)\))?$/ do |feature_name, scenario_name, timeout|
  FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
    if timeout
      Runners::ComplexRunner.set_timeout(timeout.to_i)
    end
    Runners::ComplexRunner.set_verbose(true)
    expect(Runners::InstrumentsRunner.run({:scheme=>'AgileToolbox', :feature=>feature_name, :scenario=>scenario_name})).to eq(0)
    Runners::ComplexRunner.set_verbose(false)
    Runners::ComplexRunner.reset_timeout
  end
end
