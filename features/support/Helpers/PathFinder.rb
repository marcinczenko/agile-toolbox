module Helpers
  
  class PathFinder
    @@paths = {:GoogleAppEngineAppMock => File.expand_path('GoogleAppEngineAppMock/main.py')}
    
    def self.find(key)
      @@paths[:GoogleAppEngineAppMock]
    end
    
  end
end

