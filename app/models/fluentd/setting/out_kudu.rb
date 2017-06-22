class Fluentd
  module Setting
    class OutKudu < Output
      include Common

      relate_to_details

      def self.initial_params
        sys_prop = Dataenchilada::Agents::Configurator.get_system_props
        port = get_flume_sink_port
        #
        {
            master_addresses: "#{sys_prop[:kudu_master_host]}:#{sys_prop[:kudu_master_port]}",
            master_host: "#{sys_prop[:kudu_master_host]}",
            master_port: "#{sys_prop[:kudu_master_port]}",
            flume_sink_port: "#{port}",
        }
      end

      def self.get_flume_sink_port
        last_row = Fluentd::Setting::Detail::OutKuduDetail.order("id desc").first
        if last_row
          port = last_row.flume_sink_port.to_i + 1
          #TODO - check port - busy or not
        else
          port = 33333
        end
      end

    end
  end
end
