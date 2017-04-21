module Dataenchilada::Agents
  class Manager

    COMMANDS = ['run', 'start', 'stop', 'restart']

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

      # start with supervisor
      sv_name = ::Dataenchilada::Agents::Settings::sv_service_name(agent)
      cmd = "supervisorctl start #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)


      agent.finish_start!

      return true
    end

    def self.stop(agent)
      agent.begin_stop!

      # with supervisor
      sv_name = ::Dataenchilada::Agents::Settings::sv_service_name(agent)
      cmd = "supervisorctl stop #{sv_name}"
      res = Dataenchilada::System::Commands::exec(cmd)


      agent.finish_stop!

      return true
    end

    def self.restart(agent)
      agent.begin_restart!

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
      # generate config
      res_config = Dataenchilada::Agents::Configurator.generate_config(agent)

      #agent.set_installing!

      # check config
      begin
        cmd = cmd_check_config(agent)
        res_config = Dataenchilada::System::Commands::exec(cmd)
      rescue => e
        return false
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

      cmd_run = cmd_run(agent)
      vars = OpenStruct.new(agent: agent, cmd: cmd_run)
      result = ERB.new(s_tpl).result(vars.instance_eval { binding })

      #sudo service supervisor restart
      sv_filename = ::Dataenchilada::Agents::Settings::sv_file(agent)


      File.open(sv_filename,'w') do |f|
        f.write(result)
      end

      # reload supervisor
      cmd = "service supervisor stop && service supervisor start"
      res = Dataenchilada::System::Commands::exec(cmd, false)


      true
    end


    ### helpers - operations with agent

    def self.cmd_run(agent, opts={})
      #
      config_file_path = Dataenchilada::Agents::Configurator.config_filename(agent)

      #
      opts = {config_file: config_file_path}
      opts_args = options_to_argv(agent, opts)

      # run
      %Q(fluentd #{opts_args})
    end


    def self.cmd_check_config(agent, opts={})
      #
      config_file_path = Dataenchilada::Agents::Configurator.config_filename(agent)

      #
      opts = {config_file: config_file_path}
      opts_args = options_to_argv(agent, opts)

      # run
      %Q(fluentd --dry-run #{opts_args} 2>&1)
    end



    def self.options_to_argv(agent, opts = {})
      lib = ::Dataenchilada::Agents::Settings

      argv = ""
      argv << " -c #{opts[:config_file] || lib.config_file(agent)}"
      #argv << " -d #{opts[:pid_file] || lib.pid_file(agent)}"
      #argv << " -o #{opts[:log_file] || lib.log_file(agent)}"
      argv
    end

  end
end
