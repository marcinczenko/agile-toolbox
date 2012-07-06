
Given /^Google App Engine Server Mock with (\d+) items is started$/ do |number_of_items|
    @google_mock = Runners::GoogleAppEngineMockRunner.new({:target=>'AgileToolbox',:number_of_items=>5})
    @google_mock.start()
end

After do
    @google_mock.stop()
end

Then /^I should be able to retrieve these (\d+) items using my iPhone App \(Walking_Skeleton_suite\.js\)$/ do |arg1|
  FileUtils.cd "#{ENV['HOME']}/UIAutomation/AgileToolbox/log" do
      Runners::ComplexRunner.setVerbose(true)  
      Runners::InstrumentsRunner.run({:target=>'AgileToolbox'}).should == 0
      Runners::ComplexRunner.setVerbose(false)  
  end
end
