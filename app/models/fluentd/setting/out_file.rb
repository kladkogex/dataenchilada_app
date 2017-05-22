class Fluentd
  module Setting
    class OutFile < Output
      include Common

      relate_to_details

      def self.initial_params
        {
        }
      end
    end
  end
end
