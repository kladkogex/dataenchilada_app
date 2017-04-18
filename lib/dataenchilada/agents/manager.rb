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

      # check config
      begin
        cmd = cmd_check_config(agent)
        res_config = Dataenchilada::System::Commands::exec(cmd)
      rescue => e
        return false
      end

      # run
      #cmd = %Q(fluentd -q #{opts_args} 2>&1)
      cmd = cmd_run(agent)
      return Dataenchilada::System::Commands::exec(cmd)
    end


    def self.start(agent)

      return true
    end

    def self.stop(agent)

      return true
    end

    def self.restart(agent)

      return true
    end



    ### install

    def self.install(agent)
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
