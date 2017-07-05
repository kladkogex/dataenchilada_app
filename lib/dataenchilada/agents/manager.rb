module Dataenchilada::Agents
  class Manager

    COMMANDS = ['run', 'start', 'stop', 'restart', 'delete']

    ###
    def self.logger
      Rails.logger
    end

    ###
    def self.do_command(agent, cmd)
      unless COMMANDS.include?(cmd)
        return false
      end

      #
      return send(cmd.to_sym, agent)
    end

    def self.run(agent)
      # install
      install(agent)

      # start
      start(agent)

    end


    def self.start(agent)
      agent.begin_start!

      if agent_outputs_is_kudu?(agent)
        # start with flume supervisor
        sv_name = "data_enchilada_agent_#{agent.conf_name}_flume"
        cmd = "supervisorctl start #{sv_name}"
        res = Dataenchilada::System::Commands::exec(cmd)
      end

      # start with supervisor
      sv_name = ::Dataenchilada::Agents::Settings::sv_service_name(agent)
      cmd = "supervisorctl start #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)

      agent.finish_start!

      return true
    end

    def self.stop(agent)
      agent.begin_stop!

      if agent_outputs_is_kudu?(agent)
        # start with flume supervisor
        sv_name = "data_enchilada_agent_#{agent.conf_name}_flume"
        cmd = "supervisorctl stop #{sv_name}"
        res = Dataenchilada::System::Commands::exec(cmd)
      end

      # with supervisor
      sv_name = ::Dataenchilada::Agents::Settings::sv_service_name(agent)
      cmd = "supervisorctl stop #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)

      agent.finish_stop!

      return true
    end

    def self.restart(agent)
      agent.begin_restart!

      if agent_outputs_is_kudu?(agent)
        # stop with flume supervisor
        sv_name = "data_enchilada_agent_#{agent.conf_name}_flume"
        cmd = "supervisorctl stop #{sv_name}"
        res = Dataenchilada::System::Commands::exec(cmd)

        # start with flume supervisor
        cmd = "supervisorctl start #{sv_name}"
        res = Dataenchilada::System::Commands::exec(cmd)
      end


      # with supervisor
      sv_name = ::Dataenchilada::Agents::Settings::sv_service_name(agent)
      cmd = "supervisorctl stop #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)

      cmd = "supervisorctl start #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)



      agent.finish_restart!

      return true
    end



    ### install

    def self.install(agent)
      # for flume to kudu
      agent.outputs.each do |t|
        if t.type == "Fluentd::Setting::OutKudu"
          # generate config
          flume_conf = Dataenchilada::Agents::Configurator.flume_generate_config(agent, t.id)
          # install with supervisor
          install_service_supervisor_flume(agent)
        end
      end

      # generate config
      res_config = Dataenchilada::Agents::Configurator.generate_config(agent)

      #agent.set_installing!

      # check config
      begin
        cmd = cmd_check_config(agent)
        res_config = Dataenchilada::System::Commands::exec(cmd)

        logger.error "Run cmd: #{cmd}. Output: #{res_config[1]}"
      rescue => e
        logger.error "Error in config"
        logger.error "Error in config: #{res_config.try(:[],1)}, cmd: #{cmd}"
        logger.error e.message

        raise 'Error in config'
        #return false
      end

      logger.error "Config Ok. Agent: #{agent.conf_name}"

      # create mapping index in es for netflow if elasticsearch output
      if agent.name == "netflow"
        agent.outputs.each do |t|
          if t.type == "Fluentd::Setting::OutElasticsearch"
            create_index_if_elastic_output(t)
          end
        end
      end


      # install with supervisor
      install_service_supervisor(agent)


      #
      agent.finish_install!


      true
    end


    def self.install_service_supervisor(agent)
      require 'erb'
      s_tpl = File.read(File.join(Rails.root, "data/templates/#{agent.agent_type.name}/supervisor/supervisor.conf.erb"))

      cmd = build_cmd_run(agent)
      tpl_vars = OpenStruct.new(agent: agent, cmd: cmd)

      result = ERB.new(s_tpl).result(tpl_vars.instance_eval { binding })

      sv_filename = ::Dataenchilada::Agents::Settings::sv_file(agent)

      logger.debug "Try to write to file: #{sv_filename}"
      logger.debug "Content: #{result}"

      File.open(sv_filename,'w') do |f|
        f.write(result)
      end

      logger.info "Created sv file: #{sv_filename}"

      # reload supervisor
      begin
        #cmd = "service supervisor stop; service supervisor start"
        cmd = "supervisorctl reread; supervisorctl update"
        res = Dataenchilada::System::Commands::exec(cmd, true)
        logger.debug "Restart supervisor. Output: #{res[1]}"
      rescue => e
        logger.error "Cannot restart supervisor"
      end

      true
    end


    def self.install_service_supervisor_flume(agent)
      require 'erb'
      s_tpl = File.read(File.join(Rails.root, "data/templates/flume/supervisor/supervisor.conf.erb"))

      cmd = build_cmd_run_flume(agent)
      tpl_vars = OpenStruct.new(agent: agent, cmd: cmd)

      result = ERB.new(s_tpl).result(tpl_vars.instance_eval { binding })

      sv_filename = ::Dataenchilada::Agents::Settings::sv_file_flume(agent)

      logger.debug "Try to write to file: #{sv_filename}"
      logger.debug "Content: #{result}"

      File.open(sv_filename,'w') do |f|
        f.write(result)
      end

      logger.info "Created sv file: #{sv_filename}"

      # reload supervisor
      begin
        #cmd = "service supervisor stop; service supervisor start"
        cmd = "supervisorctl reread; supervisorctl update"
        res = Dataenchilada::System::Commands::exec(cmd, true)
        logger.debug "Restart supervisor. Output: #{res[1]}"
      rescue => e
        logger.error "Cannot restart supervisor"
      end

      true
    end

    ### delete

    def self.delete(agent)
      require 'fileutils'
      agent.begin_remove!
      # stop supervisor agent
      stop(agent)
      ### remove supervisor config from /etc/supervisor/conf.d/
      # get path to file
      sv_filename = ::Dataenchilada::Agents::Settings::sv_file(agent)
      # delete file
      FileUtils.rm(sv_filename)
      #File.delete(sv_filename) if File.exist?(sv_filename)
      ### remove directory_agent_name from /data/agents
      FileUtils.remove_dir(agent.base_dir, true)
      # delete input details for twitter agent
      if agent.name == "twitter" || agent.name == "forward"
        agent.source.details.destroy if agent.source.details
      end
      # delete output details for kudu
      agent.outputs.each do |t|
        if t.type == "Fluentd::Setting::OutKudu"
          t.details.destroy
          # remove supervisor config from /etc/supervisor/conf.d/
          sv_filename_flume = ::Dataenchilada::Agents::Settings::sv_file_flume(agent)
          FileUtils.rm(sv_filename_flume)
        end
      end

      ### change status to removed
      agent.finish_remove!
    end

    ### helpers - operations with agent

    def self.build_cmd_run(agent, opts={})
      #
      # config_file_path = Dataenchilada::Agents::Configurator.config_filename(agent)

      #
      #opts = {config_file: agent.config_path, log_file: agent.log_path}
      opts_args = options_to_argv(agent, opts)

      # run
      %Q(fluentd #{opts_args})
    end

    # for flume to kudu
    def self.build_cmd_run_flume(agent)
      # run
      %Q(flume-ng agent -n #{agent.tag} -c #{agent.base_dir} -f #{agent.flume_config_path})
    end


    def self.cmd_check_config(agent, opts={})
      #
      config_file_path = Dataenchilada::Agents::Configurator.config_filename(agent)

      #
      opts = {config_file: config_file_path}
      opts_args = options_to_argv(agent, opts)

      # run
      %Q(fluentd --dry-run #{opts_args})
    end



    def self.options_to_argv(agent, opts = {})

      lib = ::Dataenchilada::Agents::Settings

      argv = ""


      argv << " -c #{agent.config_path || opts[:config_file] || lib.config_file(agent)}"
      #argv << " -d #{opts[:pid_file] || lib.pid_file(agent)}"
      argv << " -o #{agent.log_path || opts[:log_file] || lib.log_file(agent)}"
      argv
    end

    def self.agent_outputs_is_kudu?(agent)
      # delete output details for kudu
      agent.outputs.each do |t|
        if t.type == "Fluentd::Setting::OutKudu"
          return true
        end
      end
      false
    end


    def self.create_index_if_elastic_output(output)
      #
      index_name = output.details.index_name
      type_name =  output.details.type_name
      # get system props
      sys_prop = Dataenchilada::Agents::Configurator.get_system_props
      elastic_host = sys_prop[:elasticsearch_host]
      elastic_port = sys_prop[:elasticsearch_port] || 9200
      # create elasticsearch index
      Dataenchilada::Agents::CreateIndexElasticForNetflow.index_create(index_name, type_name, elastic_host, elastic_port)
    end


  end
end
