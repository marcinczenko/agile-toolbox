module Runners
    
  class ComplexRunner
      @@timeout = 20
      @@verbose = false
      def self.run(command,signal='INT')
          runner = SimpleRunner.new(command)
          runner.start
          hangupDetector = HangupDetector.new([runner],@@timeout,signal)
          exit_status = runner.wait
          hangupDetector.stop
          if @@verbose
              puts runner.output
          end
          if !exit_status.success? || !runner.exited_normally?
              1
          else
              0
          end
      end
      
      def self.set_verbose(value)
          @@verbose = value
      end
  end
end
