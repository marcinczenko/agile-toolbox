FileUtils.rm_rf "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"
FileUtils.mkdir_p "#{Helpers::PathFinder.find(:UIAutomation_build)}/AgileToolbox/log"

preprocessor = 'TEST NO_STATE_PRESERVATION NO_QUESTIONS_HELPER_OVERLAY'

if not ENV['RUN_ON_GAE']
  preprocessor += " QUESTIONS_URL=#{Capybara.app_host.sub(/^https*:\/\//,'')}"
end

Runners::ComplexRunner.set_verbose(true)
Runners::XcodebuildRunner.run({:scheme=>'AgileToolbox',:preprocessor=>preprocessor}).should == 0
Runners::ComplexRunner.set_verbose(false)

if ENV['RUN_ON_GAE_DEVELOPMENT']

  gae_runner = Runners::GoogleAppEngineDevelopmentServerRunner.new({})
  begin
    gae_runner.start
  rescue
    print 'Stopping GAE DEV...'
    gae_runner.stop
    puts 'OK'
    exit(1)
  end

  at_exit do
    print 'Stopping GAE DEV...'
    gae_runner.stop
    puts 'OK'
  end
end
