module Runners
  
  class XcodebuildRunner < ComplexRunner
    def self.command(target)
        "xcodebuild -target #{target} -configuration Release -sdk iphonesimulator5.1 OBJROOT='#{ENV['HOME']}/UIAutomation/#{target}/build/obj' SYMROOT='#{ENV['HOME']}/UIAutomation/#{target}/build/bin' build"
    end
    
    def self.run(options)
        cmd = command(options[:target])
        if @@verbose
            puts cmd
        end
        super(cmd)
    end
    
  end
end
