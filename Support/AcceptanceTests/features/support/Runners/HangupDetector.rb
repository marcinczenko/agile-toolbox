module Runners

    class HangupDetector

        def initialize (arrayOfProcessesToBeNotified, timeout, signal)
            @observers = Array.new
            arrayOfProcessesToBeNotified.each do |observer|
                add_observer(observer)
            end            
            @monitor_stop = false
            @signal = signal
            @monitor_thread = Thread.new { run(timeout) }
        end

        def add_observer(observer)
            @observers << observer
        end

        def run(timeout)
            time_running = 0
            until @monitor_stop do
              sleep(1)
              time_running += 1
              break if time_running > timeout
            end
            unless @monitor_stop
              @observers.each do |observer|
                observer.notify(@signal)
              end
            end
        end

        def stop
            @monitor_stop = true
            @monitor_thread.join
        end
    end
end
