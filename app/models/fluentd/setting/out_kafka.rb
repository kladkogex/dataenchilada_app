class Fluentd
  module Setting
    class OutKafka < Output
      include Common

      relate_to_details
=begin
      def self.initial_params
        {
          zookeeper: "#{Fluentd::KAFKA_SERVER}:2181",
          # schema_registry: "http://#{Fluentd::KAFKA_SERVER}:8081",
          output_data_type: 'json'
        }
      end
=end

      def self.initial_params
        sys_prop = Dataenchilada::Agents::Configurator.get_system_props
        #
        {
            brokers: "#{sys_prop[:kafka_host]}:#{sys_prop[:kafka_port]}",
            zookeeper: "#{sys_prop[:zookeeper_host]}:#{sys_prop[:zookeeper_port]}",

            flush_interval: "5s",
            #default_topic: "fluentd_api_access_nginx",
            max_send_retries: 1,
            required_acks: -1,
            output_data_type: 'json',
        }
      end

    end
  end
end
