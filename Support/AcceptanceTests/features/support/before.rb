FileUtils.rm_rf "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"
FileUtils.mkdir_p "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"

Runners::ComplexRunner.set_verbose(true)
Runners::XcodebuildRunner.run({:scheme=>'AgileToolbox'}).should == 0
Runners::ComplexRunner.set_verbose(false)