module Runners
  
  class InstrumentsRunner < ComplexRunner
    def self.command(options)
        # template = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
        template = "/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
        app = "#{ENV['HOME']}/UIAutomation/#{options[:scheme]}/build/bin/Release-iphonesimulator/AgileToolbox.app"
        script = "#{Helpers::PathFinder.find(:WORKSPACE)}/UIAutomation/specs/#{options[:feature]}/#{options[:scenario]}.js"
        log = "#{ENV['HOME']}/UIAutomation/#{options[:scheme]}/log"
        "instruments -t '#{template}' '#{app}' -e UIASCRIPT '#{script}' -e UIARESULTSPATH '#{log}' 2>&1" 
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
            parseLogFile(options[:scheme])
        end 
    end
    
    def self.parseLogFile(scheme)
        parser = Helpers::Parser.new("#{ENV['HOME']}/UIAutomation/#{scheme}/log/Run 1/Automation Results.plist")
        if @@verbose
            puts parser.output
        end
        parser.exit_code
    end
  end
end
