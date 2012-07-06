module Runners
    
  class ComplexRunner
      @@timeout = 20
      @@verbose = false
      def self.run(command)
          runner = SimpleRunner.new(command)
          runner.start()
          hangupDetector = HangupDetector.new([runner],@@timeout)
          exit_status = runner.wait()
          hangupDetector.stop()
          if @@verbose
              puts runner.output()
          end
          if !exit_status.success? || !runner.exited_normally?
              1
          else
              0
          end
      end
      
      def self.setVerbose(value)
          @@verbose = value
      end
  end
end
