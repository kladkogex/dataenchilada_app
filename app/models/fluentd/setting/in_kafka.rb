class Fluentd
  module Setting
    class InKafka < Source

      relate_to_details
      # include ActiveModel::Model
      include Common

      KEYS = [
          :brokers,
          :topics,
          :format,
          :message_key,
          :add_prefix,
          :add_suffix,
          :offset_zookeeper,
          :offset_zk_root_node,
          :max_bytes,
          :max_wait_time,
          :min_bytes
      ].freeze

      # attr_accessor(*KEYS)

      def self.initial_params
        sys_prop = Dataenchilada::Agents::Configurator.get_system_props
        #
        {
            brokers: "#{sys_prop[:kafka_host]}:#{sys_prop[:kafka_port]}",
            #brokers: "#{Fluentd::KAFKA_SERVER}:2181",
            format: 'json'
        }
      end

      def common_options
        [
          :brokers, :topics, :format
        ]
      end

      def advanced_options
        [
            :message_key,
            :add_prefix,
            :add_suffix,
            :offset_zookeeper,
            :offset_zk_root_node,
            :max_bytes,
            :max_wait_time,
            :min_bytes
        ]
      end

      def fields_descriptions
        {
            brokers: 'The list of comma-separated seed brokers, with their host and port information.',
            topics: "Comma-separated list of topics",
            #format: '<input text type (text|json|ltsv|msgpack)> :default => json',
            message_key: 'Optional, for text format only, default is message>',
            add_prefix: '<tag prefix (Optional)>',
            add_suffix: '<tag suffix (Optional)>',
            offset_zookeeper: '<zookeer node list (<zookeeper1_host>:<zookeeper1_port>,<zookeeper2_host>:<zookeeper2_port>,..)>',
            offset_zk_root_node: "'<offset path in zookeeper> default => '/fluent-plugin-kafka'",
            #max_bytes: '(integer) :default => nil (Use default of ruby-kafka)',
            #max_wait_time: '(integer) :default => nil (Use default of ruby-kafka)',
            #min_bytes: '(integer) :default => nil (Use default of ruby-kafka)'
        }
      end

      def fields_types
        {
            format: {type: 'dropdown', values: ['json', 'text', 'ltsv', 'msgpack']},
            add_prefix: {type: 'hidden'},
            add_suffix: {type: 'hidden'},
            offset_zookeeper: {type: 'hidden'},
            offset_zk_root_node: {type: 'hidden'},
        }
      end


      def self.default_tag
        'type_expected_kafka_tag'
      end

      def plugin_name
        'kafka'
      end
    end
  end
end
