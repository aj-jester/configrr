require 'faraday'
require 'json'
require 'active_support/core_ext/hash/deep_merge'

module Configrr
  module Foreman
    def self.connect
      if @conn.nil?
        @conn = Faraday.new(url: "https://#{Configrr::Config.get['foreman']['host']}/api/v2") do |builder|
          builder.use Faraday::Request::Retry
          builder.use Faraday::Request::BasicAuthentication, Configrr::Config.get['foreman']['username'], Configrr::Config.get['foreman']['password']
          builder.use Faraday::Adapter::NetHttp
        end
      end
      @conn
    end

    def self.hosts

      Configrr::Log.debug "Attempting to get hosts list from #{Configrr::Config.get['foreman']['host']}."

      page = 0
      foreman_hosts = [0]
      all_hosts = Hash.new

      until foreman_hosts.empty? do
        page += 1

        begin
          get_hosts = Configrr::Foreman.connect.get(
            'hosts',
            { per_page: 100, page: page, order: 'name ASC' }
          )
        rescue Faraday::ConnectionFailed => e
          Configrr::Log.error e.message
        end

        Configrr::Log.error "Unable to get foreman hosts. (#{get_hosts.status})" unless get_hosts.status == 200

        foreman_hosts = JSON.parse(get_hosts.body)["results"].map do |host|
          unless Configrr::Config.get['foreman']['exclude_hostgroups'].include?(host['hostgroup_name'])
            all_hosts[host['name']] = {
              'ip'        => host['ip'],
              'fqdn'      => host['name'],
              'subnet'    => host['subnet_name'],
              'hostgroup' => host['hostgroup_name'],
              'location'  => host['location_name'],
            }
          end
        end
      end

      total_hosts = all_hosts.size

      Configrr::Log.debug({
        'total_foreman_hosts' => total_hosts,
        'message' => "Got #{total_hosts} hosts from Foreman."
      })

      all_hosts
    end

    def self.facts

      all_hosts = Hash.new

      Configrr::Config.get['foreman']['facts'].map do |fact_name|

        Configrr::Log.debug "Fetch hosts with fact #{fact_name}."

        page = 0
        foreman_hosts = [0]

        until foreman_hosts.empty? do
          page += 1

          begin
            get_hosts = Configrr::Foreman.connect.get(
              'fact_values',
              { per_page: 1000, page: page, search: "name=#{fact_name}", order: 'host ASC' }
            )
          rescue Faraday::ConnectionFailed => e
            Configrr::Log.error e.message
          end

          Configrr::Log.error "Unable to get foreman facts for hosts. (#{get_hosts.status})" unless get_hosts.status == 200

          foreman_hosts = JSON.parse(get_hosts.body)["results"]

          all_hosts.deep_merge!(foreman_hosts)
        end

      end

      all_hosts
    end

  end
end
