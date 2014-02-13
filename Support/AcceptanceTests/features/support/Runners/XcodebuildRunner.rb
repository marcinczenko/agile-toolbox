module Runners
  
  class XcodebuildRunner < ComplexRunner

    def self.xcode_workspace(options)
      "#{Helpers::PathFinder.find(:WORKSPACE)}/AgileToolbox.xcworkspace"
    end

    def self.configuration
      'release'
    end

    def self.sdk
      'iphonesimulator7.0'
    end

    def self.obj_root(options)
      "#{Helpers::PathFinder.find(:UIAutomation_build)}/#{options[:scheme]}/build/obj"
    end

    def self.sym_root(options)
      "#{Helpers::PathFinder.find(:UIAutomation_build)}/#{options[:scheme]}/build/bin"
    end

    def self.command(options)
        "xcodebuild -workspace #{xcode_workspace(options)} -scheme #{options[:scheme]} -configuration #{configuration} -sdk #{sdk} OBJROOT='#{obj_root(options)}' SYMROOT='#{sym_root(options)}' GCC_PREPROCESSOR_DEFINITIONS='#{options[:preprocessor]}' build"
    end
    
    def self.run(options)
        cmd = command(options)
        if @@verbose
            puts cmd
        end
        super(cmd)
    end
    
  end
end
