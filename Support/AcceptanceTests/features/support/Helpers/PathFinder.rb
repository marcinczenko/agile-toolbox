module Helpers

  
  class PathFinder

    SUPPORT_DIRECTORY_PATH = __FILE__.gsub(/\/Support.*$/,'/Support')
    WORKSPACE_DIRECTORY_PATH = SUPPORT_DIRECTORY_PATH.gsub(/\/AgileToolbox.*$/,'/AgileToolbox')
    IPHONE_SIMULATOR_PATH = "#{ENV['HOME']}/Library/Application Support/iPhone Simulator"
    APPLICATIONS_PATH = "#{Dir.glob("#{IPHONE_SIMULATOR_PATH}/7.*-64").last}/Applications"
    APPNAME = 'AgileToolbox.app'

    def self.find_app_sandbox_folder
      Dir.foreach(APPLICATIONS_PATH) do |file_name|
        if /^[\dA-F]{8}-[\dA-F]{4}-[\dA-F]{4}-[\dA-F]{4}-[\dA-F]{12}$/ =~ file_name
          if File.exists?(File.join("#{APPLICATIONS_PATH}",file_name,APPNAME))
            return File.join("#{APPLICATIONS_PATH}",file_name)
          end
        end
      end
    end

    if nil == ENV['VIRTUAL_ENV']
      ENV['VIRTUAL_ENV'] = "#{ENV['HOME']}/.virtualenvs/agiletoolbox"
    end

    def self.paths
      {:Python => "#{File.join(ENV['VIRTUAL_ENV'], '/bin/python')}",
       :GoogleAppEngineAppMock => File.expand_path("#{SUPPORT_DIRECTORY_PATH}/GoogleAppEngineAppMock/main.py"),
       :WORKSPACE => WORKSPACE_DIRECTORY_PATH,
       :UIAutomation_scripts => File.expand_path("#{SUPPORT_DIRECTORY_PATH}/UIAutomation"),
       :UIAutomation_build => "#{ENV['HOME']}/UIAutomation",
       :Applications => APPLICATIONS_PATH,
       :AppName => APPNAME,
       :ApplicationSandbox => self.find_app_sandbox_folder,
       :GoogleAppEngineWebApp => File.expand_path(File.join(WORKSPACE_DIRECTORY_PATH,'../DemoWebApp'))}
    end

    def self.find(key)
      self.paths[key]
    end
  end
end
