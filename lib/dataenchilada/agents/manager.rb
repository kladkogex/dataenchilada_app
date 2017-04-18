module Dataenchilada::Agents
  class Manager

    COMMANDS = ['start', 'stop', 'restart']

    def self.do_command(agent, cmd)
      unless COMMANDS.include?(cmd)
        return false
      end

      #
      return send(cmd.to_sym, agent)
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
  end
end
