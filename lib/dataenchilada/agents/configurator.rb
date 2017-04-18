module Dataenchilada::Agents
  class Configurator


    def self.config_filename(agent)
      File.join(Rails.root, "data/agents/", "#{agent.name}.conf")
    end
  end
end
