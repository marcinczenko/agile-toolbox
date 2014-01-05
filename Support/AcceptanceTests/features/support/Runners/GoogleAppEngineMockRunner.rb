module Runners
  
    class GoogleAppEngineMockRunner
        
        def initialize(options)
            @options = options
            @cmd = command
            @verbose = false
        end
    
        def start
            if @verbose
                puts @cmd
            end
            @runner = SimpleRunner.new(@cmd)
            @runner.start
            wait_for_being_operational
        end
        
        def verbose
            @verbose
        end

        def set_verbose(verbose)
            @verbose = verbose
        end

        def stop
            @runner.notify('INT')
        end
              
        def command
            "#{Helpers::PathFinder.find(:Python)} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}"
            #"#{File.join(ENV['VIRTUAL_ENV'], '/bin/python')} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}"
        end
        
        def wait_for_being_operational
            begin
                Capybara.default_wait_time = 7
                wait_until { ready?('http://192.168.1.33:9001/ready')  }
                yield if block_given?
            rescue TimeoutError
                raise 'GoogleAppEngine Mock does not appear to be operational.'
            end
        end

        # in Capybara 2 there is no wait_until anymore...
        def wait_until
            require 'timeout'
            Timeout.timeout(Capybara.default_wait_time) do
                sleep(0.1) until (value = yield)
                value
            end
        end
        
        def ready?(path)
            uri = URI.parse(path)
            http = Net::HTTP.new(uri.host, uri.port)
            
            begin
                request = Net::HTTP::Get.new(uri.request_uri)
                response = http.request(request)

                if response.is_a?(Net::HTTPOK)
                    true
                else
                    false
                end
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
                false
            end
            
        end
    
    end
end
