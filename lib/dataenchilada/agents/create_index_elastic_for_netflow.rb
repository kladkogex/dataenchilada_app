module Dataenchilada::Agents
  class CreateIndexElasticForNetflow

    require 'elasticsearch'
    require 'elasticsearch/dsl'
    include Elasticsearch::DSL

    def self.index_create(index_name, type_name, elastic_host, elastic_port)

      index = index_name
      type = type_name

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

