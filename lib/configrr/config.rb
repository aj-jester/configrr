require 'yaml'

module Configrr
  module Config
    def self.get
      if @config.nil?

        config_file = [

          # Config loads in this order
          '/etc/configrr/config.yml',
          "#{ENV['HOME']}/.configrr/config.yml",

        ].select { |config| File.file? config }.first

        if config_file.nil?
          raise Configrr::Error::ConfigENOENT, 'Config file not found'
        end

        @config = YAML.load_file config_file
      end

      @config
    end    
  end
end
