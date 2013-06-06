FileUtils.rm_rf "#{ENV['HOME']}/UIAutomation/AgileToolbox/log"
FileUtils.mkdir_p "#{ENV['HOME']}/UIAutomation/AgileToolbox/log"

Runners::ComplexRunner.setVerbose(true)  
Runners::XcodebuildRunner.run({:scheme=>'AgileToolbox'}).should == 0
Runners::ComplexRunner.setVerbose(false)