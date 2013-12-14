module Runners
  
    class GoogleAppEngineMockRunner
        
        def initialize (options)
            @options = options
            ENV["SSL_CERT_FILE"] = File.expand_path("GoogleAppEngineAppMock/CA/new-quantumagiletoolbox-dev.appspot.com/ca.pem")
            @cmd = command()
            @verbose = false
            
        end
    
        def start()
            if @verbose
                puts @cmd
                puts ENV["SSL_CERT_FILE"]
            end
            @runner = SimpleRunner.new(@cmd)
            @runner.start()
            waitForBeingOperational()
        end
        
        def verbose
            @verbose
        end

        def setVerbose(verbose)
            @verbose = verbose
        end

        def stop()
            # We have use a separate runner to kill the app becuase we running as the root user.
            # killer = SimpleRunner.new("sudo kill -s INT #{@runner.pid()}")
            puts "sudo pkill -f '#{File.join(ENV['VIRTUAL_ENV'],"/bin/python")} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}'"
            killer = SimpleRunner.new("sudo pkill -f '#{File.join(ENV['VIRTUAL_ENV'],"/bin/python")} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}'")
            killer.start()
            killer.wait()
        end
              
        def command()
            # "sudo #{File.join(ENV['WORKON_HOME'],"#{@options[:virtualenv]}/bin/python")} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}"
            "sudo #{File.join(ENV['VIRTUAL_ENV'],"/bin/python")} #{Helpers::PathFinder.find(:GoogleAppEngineAppMock)} -n #{@options[:number_of_items]}"
        end
        
        def waitForBeingOperational()
            begin
                Capybara.default_wait_time = 7
                wait_until { ready?("https://quantumagiletoolbox-dev.appspot.com/ready")  }
                yield if block_given?
            rescue TimeoutError
                raise "GoogleAppEngine Mock does not appear to be operational."
            end
        end

        # in Capybara 2 there is no wait_until anymore...
        def wait_until
            require "timeout"
            Timeout.timeout(Capybara.default_wait_time) do
                sleep(0.1) until value = yield
                value
            end
        end
        
        def ready?(path)
            uri = URI.parse(path)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            # below is just to remember how to switch validation off
            # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            # puts "#{uri.request_uri}"    
            
            begin
                request = Net::HTTP::Get.new(uri.request_uri)
                response = http.request(request)

                if response.is_a?(Net::HTTPOK)
                    true
                else
                    false
                end
            rescue Errno::EHOSTUNREACH
                false
            end
            
        end
    
    end
end
