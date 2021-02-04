require 'base64'
require 'active_support/core_ext/hash/deep_merge'

module Configrr
  module Hosts
    def self.foreman_hosts
      Configrr::Foreman.hosts.deep_merge Configrr::Foreman.facts
    end

    def self.consul_hosts kv_prefix
      consul_kv = Configrr::Consul.get_kv kv_prefix

      hosts = Hash.new

      consul_kv.map do |kv|
        key_split = kv['Key'].gsub("#{kv_prefix}", '').split('/', 2)
        hostname  = key_split.first
        key_name  = key_split.last

        hosts[hostname] = Hash.new unless hosts.key?(hostname)

        if kv['Value'].nil?
          Configrr::Log.debug "Ignoring Key: #{key_name} with Nil value for Host: #{hostname}."
        else
          hosts[hostname][key_name] = Base64.decode64(kv['Value'])
        end
      end

      hosts
    end

    def self.agentless_hosts

      if @agentless.nil?
        agentless_hosts_file = [

          # Config loads in this order
          '/etc/configrr/agentless_hosts.yml',
          "#{ENV['HOME']}/.configrr/agentless_hosts.yml",

        ].select { |config| File.file? config }.first

        if agentless_hosts_file.nil?

          Configrr::Log.debug 'No agentless hosts found.'
          @agentless = Hash.new
        else
          Configrr::Log.debug "Loading agentless hosts from #{agentless_hosts_file}."
          @agentless = YAML.load_file agentless_hosts_file
        end
      end

      @agentless
    end

  end
end
