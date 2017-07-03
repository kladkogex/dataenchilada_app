class Fluentd
  module Setting
    class OutForward < Output

      include Common
      relate_to_details

      KEYS = [
        :match,
        :send_timeout, :recover_wait, :heartbeat_type, :heartbeat_interval,
        :phi_threshold, :hard_timeout,
        :server_name, :server_host, :server_port, :server_weight,
      ].freeze

      def self.initial_params
        {
            #heartbeat_type: "upd", # or "tcp"
        }
      end

      def common_options
        [
          #:match, :server, :secondary,
        ]
      end

      def advanced_options
        [
          :send_timeout, :recover_wait, :heartbeat_type, :heartbeat_interval,
          :phi_threshold, :hard_timeout,
        ]
      end

      def self.stream_field_name
        'server'
      end
    end
  end
end
