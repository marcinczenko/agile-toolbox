
Before do
  puts "Cleaning #{Helpers::PathFinder.find(:ApplicationSandbox)}/Library/Application Support"
  FileUtils.rm_rf "#{Helpers::PathFinder.find(:ApplicationSandbox)}/Library/Application Support"
end

Before('@preservation') do
  if !$already_run
    puts 'PRESERVATION :__+)))'
    Runners::ComplexRunner.set_verbose(true)
    Runners::XcodebuildRunner.run({:scheme=>'AgileToolbox',:preprocessor=>'TEST'}).should == 0
    Runners::ComplexRunner.set_verbose(false)
    $already_run = true
  end
end

After do
  @google_mock.stop()
end

Given /^Google App Engine Server Mock with (\d+) items (?:and (\d+) seconds delay )?is started$/ do |number_of_items,delay|
    @google_mock = Runners::GoogleAppEngineMockRunner.new({:virtualenv=>'GoogleAppEngineAppMock',:number_of_items=>number_of_items, :delay=>delay})
    @google_mock.set_verbose(true)
    @google_mock.start()
end

Then /^I should be able to retrieve these (\d+) items using my iPhone App \(Feature: "(.*?)" Scenario:"(.*?)"\)$/ do |_, featureName, scenarioName|
    FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
          Runners::ComplexRunner.set_verbose(true)
          Runners::InstrumentsRunner.run({:scheme=>'AgileToolbox', :feature=>featureName, :scenario=>scenarioName}).should == 0
          Runners::ComplexRunner.set_verbose(false)
    end
end

Then /^I should be able to add a new item using my iPhone App \(Feature: "(.*?)" Scenario:"(.*?)"\)$/ do |featureName, scenarioName|
    FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
          Runners::ComplexRunner.set_verbose(true)
          Runners::InstrumentsRunner.run({:scheme=>'AgileToolbox', :feature=>featureName, :scenario=>scenarioName}).should == 0
          Runners::ComplexRunner.set_verbose(false)
    end
end


Then /^RUN: Feature: "(.*?)" Scenario:"(.*?)"(?: \(timeout:(\d+)\))?$/ do |feature_name, scenario_name, timeout|
  FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
    if timeout
      Runners::ComplexRunner.set_timeout(timeout.to_i)
    end
    Runners::ComplexRunner.set_verbose(true)
    Runners::InstrumentsRunner.run({:scheme=>'AgileToolbox', :feature=>feature_name, :scenario=>scenario_name}).should == 0
    Runners::ComplexRunner.set_verbose(false)
    Runners::ComplexRunner.reset_timeout
  end
end
