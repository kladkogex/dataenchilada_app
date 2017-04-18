module Dataenchilada::Agents
  class Configurator


    def self.generate_config(agent)

    end


    def self.config_filename(agent)
      File.join(Rails.root, "data/agents/#{agent.name}", "fluent.conf")
    end
  end
end
