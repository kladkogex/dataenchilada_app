module Dataenchilada::Agents
  class CreateKuduTable

    require 'impala'

    def self.table_create(impala_host, impala_port, source_name, table_name)

      connect = Impala.connect(impala_host, impala_port)

      # create kudu table for netflow
      if source_name == "netflow"
        command = connect.execute("
          CREATE TABLE #{table_name} (
            id BIGINT,
            version STRING,
            uptime STRING,
            flow_records STRING,
            flow_seq_num STRING,
            engine_type STRING,
            engine_id STRING,
            sampling_algorithm STRING,
            sampling_interval STRING,
            ipv4_src_addr STRING,
            ipv4_dst_addr STRING,
            ipv4_next_hop STRING,
            input_snmp STRING,
            output_snmp STRING,
            in_pkts STRING,
            in_bytes STRING,
            first_switched STRING,
            last_switched STRING,
            l4_src_port STRING,
            l4_dst_port STRING,
            tcp_flags STRING,
            protocol STRING,
            src_tos STRING,
            src_as STRING,
            dst_as STRING,
            src_mask STRING,
            dst_mask STRING,
            host STRING,
            process_time DATETIME,
            processed_at DATETIME,
            PRIMARY KEY(id, process_time, processed_at),
            )
          PARTITION BY HASH PARTITIONS 16
          STORED AS KUDU
          TBLPROPERTIES ( 'kudu.num_tablet_replicas' = 1, 'kudu.table_name' = #{table_name});
        ")
      end


      #
      connect.close

    end
  end
end
=begin
      # set client
      client = Elasticsearch::Client.new trace: true, host: elastic_host, port: elastic_port

      # check index exists
      exists = client.indices.exists? index: index
      # create new index
      client.indices.create index: index, type: type unless exists

      # mapping index
      client.indices.put_mapping index: index, type: type, body: {
          "#{type}" => {
              dynamic: true,
              properties: {
                  :version => {:type => 'long', :index => :not_analyzed},
                  :uptime => {:type => 'long', :index => :not_analyzed},
                  :flow_records => {:type => 'long', :index => :not_analyzed},
                  :flow_seq_num => {:type => 'long', :index => :not_analyzed},
                  :engine_type => {:type => 'long', :index => :not_analyzed},
                  :engine_id => {:type => 'long', :index => :not_analyzed},
                  :sampling_algorithm => {:type => 'long', :index => :not_analyzed},
                  :sampling_interval => {:type => 'long', :index => :not_analyzed},
                  :ipv4_src_addr => {:type => 'ip', :index => :not_analyzed},
                  :ipv4_dst_addr => {:type => 'ip', :index => :not_analyzed},
                  :ipv4_next_hop => {:type => 'ip', :index => :not_analyzed},
                  :input_snmp => {:type => 'long', :index => :not_analyzed},
                  :output_snmp => {:type => 'long', :index => :not_analyzed},
                  :in_pkts => {:type => 'long', :index => :not_analyzed},
                  :in_bytes => {:type => 'long', :index => :not_analyzed},
                  :first_switched => {:type => 'long', :index => :not_analyzed},
                  :last_switched => {:type => 'long', :index => :not_analyzed},
                  :l4_src_port => {:type => 'long', :index => :not_analyzed},
                  :l4_dst_port => {:type => 'long', :index => :not_analyzed},
                  :tcp_flags => {:type => 'long', :index => :not_analyzed},
                  :protocol => {:type => 'long', :index => :not_analyzed},
                  :src_tos => {:type => 'long', :index => :not_analyzed},
                  :src_as => {:type => 'long', :index => :not_analyzed},
                  :dst_as => {:type => 'long', :index => :not_analyzed},
                  :src_mask => {:type => 'long', :index => :not_analyzed},
                  :dst_mask => {:type => 'long', :index => :not_analyzed},
                  :host => {:type => 'string', :index => :not_analyzed},
                  :process_time => {:type => 'date', :index => :not_analyzed},
                  :processed_at => {:type => 'date', :index => :not_analyzed},
              }
          }
      }

    end
  end
end

=end
