module Configrr::Cli
  module Generate
    def self.command
      @cmd ||= Cri::Command.define do
        name 'generate'
        usage 'generate [options]'
        description 'Generate app specific configuration.'
        summary 'Generate app specific configuration.'

        required :t, :type, "Generate type", :argument => :required

        run do |opts, args, cmd|
          Configrr::Opts.cli opts
          Configrr::Actions::Generate.run
        end

      end
    end
  end
  self.command.add_command Generate.command
end
