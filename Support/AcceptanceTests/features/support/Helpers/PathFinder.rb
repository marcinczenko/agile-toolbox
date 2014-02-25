module Helpers

  
  class PathFinder

    SUPPORT_DIRECTORY_PATH = __FILE__.gsub(/\/Support.*$/,'/Support')
    WORKSPACE_DIRECTORY_PATH = SUPPORT_DIRECTORY_PATH.gsub(/\/AgileToolbox.*$/,'/AgileToolbox')

    if nil == ENV['VIRTUAL_ENV']
      ENV['VIRTUAL_ENV'] = "#{ENV['HOME']}/.virtualenvs/GoogleAppEngineAppMock"
    end

    @@paths = {:Python => "#{File.join(ENV['VIRTUAL_ENV'], '/bin/python')}",
               :GoogleAppEngineAppMock => File.expand_path("#{SUPPORT_DIRECTORY_PATH}/GoogleAppEngineAppMock/main.py"),
               :WORKSPACE => WORKSPACE_DIRECTORY_PATH,
               :UIAutomation_scripts => File.expand_path("#{SUPPORT_DIRECTORY_PATH}/UIAutomation"),
               :UIAutomation_build => "#{ENV['HOME']}/UIAutomation",
               :Application_Sandbox => "#{ENV['HOME']}/Library/Application Support/iPhone Simulator/7.0.3-64/Applications/D7D885DC-3FFF-4930-B3F7-FB8B344B1B16"}

    
    def self.find(key)
      @@paths[key]
    end
    
  end
end
