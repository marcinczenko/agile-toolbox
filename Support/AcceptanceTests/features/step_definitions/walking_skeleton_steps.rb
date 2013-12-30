
Given /^Google App Engine Server Mock with (\d+) items is started$/ do |number_of_items|
    @google_mock = Runners::GoogleAppEngineMockRunner.new({:virtualenv=>'GoogleAppEngineAppMock',:number_of_items=>number_of_items})
    @google_mock.set_verbose(true)
    @google_mock.start()
end

After do
    @google_mock.stop()
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


Then /^RUN: Feature: "(.*?)" Scenario:"(.*?)"$/ do |feature_name, scenario_name|
  FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
    Runners::ComplexRunner.set_verbose(true)
    Runners::InstrumentsRunner.run({:scheme=>'AgileToolbox', :feature=>feature_name, :scenario=>scenario_name}).should == 0
    Runners::ComplexRunner.set_verbose(false)
  end
end
