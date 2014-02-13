FileUtils.rm_rf "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"
FileUtils.mkdir_p "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"

FileUtils.rm_rf "#{Helpers::PathFinder.find(:Application_Sandbox)}/Library/Application Support"

Runners::ComplexRunner.set_verbose(true)
Runners::XcodebuildRunner.run({:scheme=>'AgileToolbox',:preprocessor=>'NO_STATE_PRESERVATION TEST'}).should == 0
Runners::ComplexRunner.set_verbose(false)
