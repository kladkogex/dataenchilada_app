module Dataenchilada::Agents
  class Configurator


    ### main method

    def self.generate_config(agent)

      res = ""

      tag = ""

      # outputs
      agent.outputs.each do |output|
        s_output = generate_config_output(output, tag)

        x=0
      end




    end

    def self.generate_config_source(source, extra_args={})

    end


    def self.generate_config_output(output, tag, extra_args={})

    end

    ### helpers

    def self.config_filename(agent)
      File.join(Rails.root, "data/agents/#{agent.name}", "fluent.conf")
    end


    def self.process_erb_file(filename, vars)
      # install with supervisor
      require 'erb'
      s_tpl = File.read(filename)

      cmd_run = cmd_run(agent)
      vars = OpenStruct.new(*vars)
      result = ERB.new(s_tpl).result(vars.instance_eval { binding })


      result
    end
  end
end
