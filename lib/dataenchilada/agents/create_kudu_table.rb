module Dataenchilada::Agents
  class CreateKuduTable

    require 'impala'

    def self.table_create(impala_host, impala_port, source_name, table_name)

      connect = Impala.connect(impala_host, impala_port)

      # create kudu table for netflow
      if source_name == "netflow"
        command = connect.execute("
          CREATE TABLE IF NOT EXISTS #{table_name}
          (kudu_id BIGINT,
          kudu_processed_at STRING,
          processed_at STRING,
          flowset_id STRING,
          version STRING,
          uptime STRING,
          flow_records STRING,
          flow_seq_num STRING,
          total_flows_exp INT,
          engine_type STRING,
          engine_id STRING,
          sampling_algorithm STRING,
          sampling_interval STRING,
          ipv4_src_addr STRING,
          ipv4_dst_addr STRING,
          ipv4_next_hop STRING,
          ipv4_src_mask INT,
          ipv4_dst_mask INT,
          ipv6_src_addr STRING,
          ipv6_dst_addr STRING,
          ipv6_next_hop STRING,
          ipv6_src_mask INT,
          ipv6_dst_mask INT,
          input_snmp INT,
          output_snmp INT,
          in_pkts INT,
          total_pkts_exp INT,
          in_bytes INT,
          first_switched STRING,
          last_switched STRING,
          l4_src_port INT,
          l4_dst_port INT,
          tcp_flags INT,
          protocol INT,
          src_tos INT,
          src_as INT,
          dst_as INT,
          src_mask INT,
          dst_mask INT,
          host STRING,
          system STRING,
          PRIMARY KEY(kudu_id, kudu_processed_at))
          PARTITION BY HASH PARTITIONS 16
          STORED AS KUDU
          TBLPROPERTIES ( 'kudu.num_tablet_replicas' =  '1', 'kudu.table_name' = '#{table_name}');
        ")
      end

      #
      connect.close

    end

    def self.get_tables(impala_host, impala_port)
      connect = Impala.connect(impala_host, impala_port)
      items = connect.query("show tables;")

      connect.close
      items
    end

    def self.get_columns(impala_host, impala_port, table_name)
      connect = Impala.connect(impala_host, impala_port)
      item = connect.query("describe #{table_name};")

      connect.close
      item
    end

    def self.create_custom_table(impala_host, impala_port, columns)
      connect = Impala.connect(impala_host, impala_port)
      command = connect.execute(columns)
      connect.close
    end

    def self.prepare_table_for_demo(impala_host, impala_port, table_name, table_name2)
      connect = Impala.connect(impala_host, impala_port)
      command = connect.execute("
        CREATE TABLE IF NOT EXISTS #{table_name}
          (kudu_id BIGINT,
          kudu_processed_at STRING,
          time BIGINT,
          processed_at STRING,
          type STRING,
          fingerprint STRING,
          href STRING,
          user_agent STRING,
          browser STRING,
          browser_version STRING,
          os STRING,
          screen_print STRING,
          plugins STRING,
          time_zone STRING,
          language STRING,
          host STRING,
          port STRING,
          height INT,
          width INT,
          source STRING,
          referrer STRING,
          device STRING,
          key_code INT,
          key_char STRING,
          time_down BIGINT,
          target_down_id STRING,
          target_down_tag_name STRING,
          target_down_text STRING,
          target_down_path STRING,
          time_up BIGINT,
          target_up_id STRING,
          target_up_tag_name STRING,
          target_up_text STRING,
          target_up_path STRING,
          x INT,
          y INT,
          moved BOOLEAN,
          target_id STRING,
          target_tag_name STRING,
          target_text STRING,
          target_path STRING,
          do_alpha DOUBLE,
          do_beta DOUBLE,
          do_gamma DOUBLE,
          do_absolute BOOLEAN,
          dm_x DOUBLE,
          dm_y DOUBLE,
          dm_z DOUBLE,
          dm_gx DOUBLE,
          dm_gy DOUBLE,
          dm_gz DOUBLE,
          latitude DOUBLE,
          longitude DOUBLE,
          country_code STRING,
          country_name STRING,
          region_code STRING,
          region_name STRING,
          city STRING,
          zip_code STRING,
          metro_code INT,
          ip STRING,
          PRIMARY KEY(kudu_id, kudu_processed_at, time))
          PARTITION BY HASH PARTITIONS 16
          STORED AS KUDU
          TBLPROPERTIES ( 'kudu.num_tablet_replicas' =  '1', 'kudu.table_name' = '#{table_name}');
       ")
      connect.close

      connect = Impala.connect(impala_host, impala_port)
      command = connect.execute("
         CREATE TABLE IF NOT EXISTS #{table_name2}
          (kudu_id BIGINT,
          kudu_processed_at STRING,
          processed_at STRING,
          source STRING,
          messages STRING,
          severity STRING,
          method STRING,
          path STRING,
          format_name STRING,
          controller STRING,
          action STRING,
          status INT,
          duration DOUBLE,
          view_name DOUBLE,
          db DOUBLE,
          location_name STRING,
          PRIMARY KEY(kudu_id, kudu_processed_at))
          PARTITION BY HASH PARTITIONS 16
          STORED AS KUDU
          TBLPROPERTIES ( 'kudu.num_tablet_replicas' =  '1', 'kudu.table_name' = '#{table_name2}');
      ")
      connect.close
    end

  end
end
