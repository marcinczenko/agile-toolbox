module Runners
  
  class InstrumentsRunner < ComplexRunner

    def self.template
      '/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate'
    end

    def self.application(options)
      "#{Helpers::PathFinder.find(:UIAutomation_build)}/#{options[:scheme]}/build/bin/Release-iphonesimulator/AgileToolbox.app"
    end

    def self.log(options)
      "#{Helpers::PathFinder.find(:UIAutomation_build)}/#{options[:scheme]}/log"
    end

    def self.script(options)
      "#{Helpers::PathFinder.find(:UIAutomation_scripts)}/specs/#{options[:feature]}/#{options[:scenario]}.js"
    end

    def self.command(options)
        "instruments -t '#{template}' '#{application(options)}' -e UIASCRIPT '#{script(options)}' -e UIARESULTSPATH '#{log(options)}' 2>&1"
    end
    
    def self.run(options)
        cmd = command(options)
        if @@verbose
            puts cmd
        end
        ret = super(cmd,'KILL')
        if 0!=ret
            ret
        else
            parse_log_file(options[:scheme])
        end 
    end

    def self.find_most_recent_run_dir(scheme)
        Dir.glob("#{Helpers::PathFinder.find(:UIAutomation_build)}/#{scheme}/log/Run*").last
    end
    
    def self.parse_log_file(scheme)
        parser = Helpers::Parser.new("#{find_most_recent_run_dir(scheme)}/Automation Results.plist")
        if @@verbose
            puts parser.output
        end
        parser.exit_code
    end
  end
end
