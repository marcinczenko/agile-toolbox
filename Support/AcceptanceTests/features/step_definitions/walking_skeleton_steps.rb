
Given /^Google App Engine Server Mock with (\d+) items is started$/ do |number_of_items|
    @google_mock = Runners::GoogleAppEngineMockRunner.new({:virtualenv=>'GoogleAppEngineAppMock',:number_of_items=>5})
    @google_mock.set_verbose(true)
    @google_mock.start()
end

After do
    @google_mock.stop()
end

Then /^I should be able to retrieve these (\d+) items using my iPhone App \(Feature: "(.*?)" Scenario:"(.*?)"\)$/ do |numberOfItems, featureName, scenarioName|
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