module Dataenchilada::Agents
  class Settings

    DIR_LOGS = "/tmp/fluentd/log"
    DIR_PIDS = "/tmp/fluentd/pids"
    DIR_SUPERVISOR_CONF = "/etc/supervisor/conf.d"

    def self.pid_file(agent)
      #extra_options[:pid_file] || self.class.default_options[:pid_file]
      File.join(DIR_PIDS, "#{agent.name}.pid")
    end

    def self.log_file(agent)
      #extra_options[:log_file] || self.class.default_options[:log_file]
      File.join(DIR_LOGS, "#{agent.name}.log")
    end


    def self.config_file(agent)
      #extra_options[:config_file] || self.class.default_options[:config_file]
    end


    def self.sv_file(agent)
      File.join(DIR_SUPERVISOR_CONF, "data_enchilada_#{agent.name}.conf")

      # DEBUG
      "/tmp/fluentd/sv_data_enchilada_#{agent.name}.conf"
    end



    ### for tail

    def self.pos_file(agent)
      File.join(DIR_LOGS, "#{agent.name}.pos")
    end




  end
end

