module Dataenchilada::System
  class Commands

    def self.exec(cmd, raise_error=true)
      Bundler.with_clean_env do
        #res = system("#{cmd}", out: File::NULL, err: File::NULL)
        res = `#{cmd}`
        exit_code = $?.exitstatus

        #if !res
        if exit_code>0
          if raise_error
            raise ::Dataenchilada::Error::BaseError
          else
            return false
          end
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

