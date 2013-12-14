module Runners
  
  class XcodebuildRunner < ComplexRunner
    def self.command(options)
        # "xcodebuild -target #{options[:target]} -configuration Release -sdk iphonesimulator5.1 OBJROOT='#{ENV['HOME']}/UIAutomation/#{options[:target]}/build/obj' SYMROOT='#{ENV['HOME']}/UIAutomation/#{options[:target]}/build/bin' build"
        "xcodebuild -workspace AgileToolbox.xcworkspace -scheme #{options[:scheme]} -configuration Release -sdk iphonesimulator7.0 OBJROOT='#{ENV['HOME']}/UIAutomation/#{options[:scheme]}/build/obj' SYMROOT='#{ENV['HOME']}/UIAutomation/#{options[:scheme]}/build/bin' build"
    end
    
    def self.run(options)
        # cmd = command(options[:target])
        cmd = command(options)
        if @@verbose
            puts cmd
        end
        super(cmd)
    end
    
  end
end
