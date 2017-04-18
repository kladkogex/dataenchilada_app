module Dataenchilada::System
  class Commands

    def self.exec(cmd)
      Bundler.with_clean_env do
        #res = system("#{cmd}", out: File::NULL, err: File::NULL)
        res = `#{cmd}`
        exit_code = $?.exitstatus

        #if !res
        if exit_code>0
          raise ::Dataenchilada::Error::BaseError
        end
      end

      true
    end

    def self.detached_command(cmd)
      thread = Bundler.with_clean_env do
        pid = spawn(cmd)
        Process.detach(pid)
      end
      thread.join
      thread.value.exitstatus.zero?
    end
  end
end

