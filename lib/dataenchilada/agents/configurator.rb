module Dataenchilada::Agents
  class Configurator


    ### main method

    def self.generate_config(agent)

      res = ""

      tag = ""

      # outputs
      agent.outputs.each do |output|
        s_output = generate_config_output(output, tag)

        res << s_output

        x=0
      end

      res << "\n\n"


      # save to file
      f_out = config_filename(agent)

      File.open(f_out,'w') do |f|
        f.write(res)
      end

      true
    end

    def self.generate_config_source(source, extra_args={})

    end


    def self.generate_config_output(output, tag, extra_args={})
      agent = output.agent

      f_tpl = filename_template_output(agent.agent_type.name, output.output_type_name)

      #
      props_system = get_system_props
      props_servers = build_servers_props(props_system)
      props = build_output_props(output, tag)
      #output.details.attributes.to_hash


      tpl_vars = {
          agent: agent,
          output: output,
          props: props,
          servers: props_servers,
          system: props_system
      }

      process_erb_file(f_tpl, tpl_vars)
    end


    ### output props

    def self.build_output_props(output, tag)

      mtd = :"build_output_props_#{output.output_type_name}"
      if respond_to?(mtd)
        return send(mtd, output, tag)
      end

      nil
    end

    def self.build_output_props_elasticsearch(output, tag)
      {
          "index_name"=>"test",
          "type_name"=>tag,

      }
    end



    ### system props

    def self.get_system_props
      if Rails.env.development?
        f = File.join(Rails.root, "data/temp/data_enchilada.properties")

      end

      properties = JavaProperties.load(f)
      properties
    end


    def self.build_servers_props(props_system)

      {
          "elasticsearch"=>{
              "host"=>props_system[:elasticsearch_host],
              "port"=>props_system[:elasticsearch_port] || 9200,
          },
          'cassandra' =>{
              "host"=>props_system[:cassandra_host],
              "port"=>props_system[:cassandra_port] || 9042,
              "username"=>props_system[:cassandra_username],
              "password"=>props_system[:cassandra_password],
              "keyspace"=>props_system[:cassandra_keyspace],
          }
      }
    end

    ### helpers

    def self.config_filename(agent)
      File.join(Rails.root, "data/agents/#{agent.name}", "agent.conf")
    end

    def self.filename_template_output(agent_type, output_type)
      File.join(Rails.root, "data/templates/#{agent_type}/output/", "#{output_type}.erb")
    end


    def self.process_erb_file(filename, vars)
      # install with supervisor
      require 'erb'
      s_tpl = File.read(filename)

      vars = OpenStruct.new(vars)
      result = ERB.new(s_tpl).result(vars.instance_eval { binding })


      result
    end
  end
end
