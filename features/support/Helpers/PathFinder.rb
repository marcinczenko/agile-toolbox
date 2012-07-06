module Helpers
  
  class PathFinder
    @@paths = {:GoogleAppEngineAppMock => File.expand_path('GoogleAppEngineAppMock/main.py'),
               :WORKSPACE => File.expand_path('.')}
    
    def self.find(key)
      @@paths[key]
    end
    
  end
end

