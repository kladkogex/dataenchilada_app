class Fluentd
  module Setting
    class InNetflow < Source

      relate_to_details
      # include ActiveModel::Model
      include Common

      KEYS = [
        :bind, :port, :tag, :switched_times_from_uptime
      ].freeze

      # attr_accessor(*KEYS)

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 5140,
          tag: "netflow.tag",
          switched_times_from_uptime: "yes"
        }
      end

      def common_options
        [
          :bind, :port, :tag
        ]
      end

      def advanced_options
        [
          :switched_times_from_uptime
        ]
      end

      def plugin_name
        'netflow'
      end
    end
  end
end
