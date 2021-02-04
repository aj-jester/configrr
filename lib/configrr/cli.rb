require 'cri'

module Configrr
  module Cli
    def self.command
      @cmd ||= Cri::Command.define do
        name 'configrr'
        usage 'configrr <command> [options]'
        summary 'Config generator for services.'
        description <<-DESC
        Generate application specific configuration from ERB templates.
        DESC

        flag :v,  :verbose, 'Verbose output where possible.'
        flag nil, :force,   'Force action where possible.'

        flag :h, :help, 'Show this message.' do |value, cmd|
          puts cmd.help
          exit 0
        end

        run do |opts, args, cmd|
          puts cmd.help :verbose => true
        end
      end
    end
  end
end

require 'cli/generate'
