module Runners
  
    class GoogleAppEngineMockRunner
        
        def initialize (options)
            @options = options
            @cmd = command()
            @verbose = false
        end
    
        def start()
            if @verbose
                puts @cmd
            end
            @runner = SimpleRunner.new(@cmd)
            @runner.start()
            waitForBeingOperational()
        end
        
        def stop()
            # We have use a separate runner to kill the app becuase we running as the root user.
            killer = SimpleRunner.new("sudo kill -s INT #{@runner.pid()}")
            killer.start()
            killer.wait()
        end
              
        def command()
            "sudo #{File.join(ENV['WORKON_HOME'],"#{@options[:target]}/bin/python")} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}"
        end
        
        def waitForBeingOperational()
            begin
                Capybara.default_wait_time = 7
                Capybara.wait_until { ready?("https://quantumagiletoolbox-dev.appspot.com/ready")  }
                yield if block_given?
            rescue Capybara::TimeoutError
                raise "GoogleAppEngine Mock does not appear to be operational."
            end
        end
        
        def ready?(path)
            uri = URI.parse(path)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            # below is just to remember how to switch validation off
            # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Get.new(uri.request_uri)

            response = http.request(request)

            if response.is_a?(Net::HTTPOK)
                true
            else
                false
            end
            # puts response.body
            # puts response.code
        end
    
    end
end
