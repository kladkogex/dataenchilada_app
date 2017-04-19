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

      # run manually
      #cmd = %Q(fluentd -q #{opts_args} 2>&1)
      #cmd = cmd_run(agent)
      #return Dataenchilada::System::Commands::exec(cmd)

      # start
      start(agent)

    end


    def self.start(agent)
      agent.begin_start!


      agent.finish_start!

      return true
    end

    def self.stop(agent)
      agent.begin_stop!


      agent.finish_stop!

      return true
    end

    def self.restart(agent)
      agent.begin_restart!


      agent.finish_restart!

      return true
    end



    ### install

    def self.install(agent)

      #agent.set_installing!

      # check config
      begin
        cmd = cmd_check_config(agent)
        res_config = Dataenchilada::System::Commands::exec(cmd)
      rescue => e
        return false
      end


      # install with supervisor
      require 'erb'
      s_tpl = File.read(File.join(Rails.root, "data/templates/supervisor.conf.erb"))

      cmd_run = cmd_run(agent)
      vars = OpenStruct.new(agent: agent, cmd: cmd_run)
      result = ERB.new(s_tpl).result(vars.instance_eval { binding })

      #sudo service supervisor restart
      sv_filename = ::Dataenchilada::Agents::Settings::sv_file(agent)


      File.open(sv_filename,'w') do |f|
        f.write(result)
      end

      #
      agent.finish_install!


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
      %Q(fluentd -q #{opts_args} 2>&1)
    end


    def self.cmd_check_config(agent, opts={})
      #
      config_file_path = Dataenchilada::Agents::Configurator.config_filename(agent)

      #
      opts = {config_file: config_file_path}
      opts_args = options_to_argv(agent, opts)

      # run
      %Q(fluentd -q --dry-run #{opts_args} 2>&1)
    end



    def self.options_to_argv(agent, opts = {})
      lib = ::Dataenchilada::Agents::Settings

      argv = ""
      argv << " -c #{opts[:config_file] || lib.config_file(agent)}"
      argv << " -d #{opts[:pid_file] || lib.pid_file(agent)}"
      argv << " -o #{opts[:log_file] || lib.log_file(agent)}"
      argv
    end

  end
end
