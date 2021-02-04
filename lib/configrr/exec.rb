require 'open3'

module Configrr
  module Exec
    def self.cmd(command, opts={})

      opts = {
        exit_on_error: true,
        acceptable_exit_codes: [0],
      }.merge!(opts)

      cmd_result = {
        output: String.new,
        exit_code: nil,
      }

      begin
        Open3.popen2e(*command) do |stdin, stdout_err, wait_thr|
          cmd_result[:exit_code] = wait_thr.value

          while line = stdout_err.gets
            cmd_result[:output] << line
          end

          if opts[:exit_on_error] and not opts[:acceptable_exit_codes].include?(cmd_result[:exit_code])
            Configrr::Log.error "Command exited with #{cmd_result[:exit_code]}."
          end
        end
      rescue Errno::ENOENT
        cmd_result[:exit_code] = 127
      end

      Configrr::Log.info cmd_result
      cmd_result
    end
  end
end
