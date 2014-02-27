module Runners

  class GoogleAppEngineDevelopmentServerRunner

    def initialize(options)
      @options = options
      @cmd = command
      @verbose = false
    end

    def command
      '/usr/local/bin/dev_appserver.py --clear_datastore=yes --skip_sdk_update_check --host=0.0.0.0 --port=9001 /Users/mczenko/Projects/Quantum/GoogleAppEngineWebApp'
    end

    def start
      if @verbose
        puts @cmd
      end
      @runner = SimpleRunner.new(@cmd)
      @runner.start
      wait_for_being_operational
    end

    def stop
      @runner.notify('INT')
      @runner.wait
    end

    def wait_for_being_operational
      begin
        Capybara.default_wait_time = 7
        wait_until { ready?("#{Capybara.app_host}/ready")  }
        yield if block_given?
      rescue TimeoutError
        raise 'GoogleAppEngine Development Server does not appear to be operational.'
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
