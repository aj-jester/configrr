require 'faraday'
require 'json'

module Configrr
  module Consul

    def self.connect
      if @conn.nil?
        @conn = Faraday.new(url: Configrr::Config.get['consul']['uri'], headers: {
            'X-Consul-Token' => Configrr::Config.get['consul']['token'],
            'Content-Type'   => 'application/json',
          }) do |builder|
          builder.use Faraday::Request::Retry
          builder.use Faraday::Adapter::NetHttp
        end
      end
      @conn
    end

    def self.get_kv kv_prefix
      begin
        get_kv = self.connect.get do |req|
          req.url "/v1/kv/#{kv_prefix}"
          req.params['recurse'] = true
        end

        Configrr::Log.debug({
          'consul_exit_code' => get_kv.status,
          'message'          => "Consul prefix #{kv_prefix} get_kv status: #{get_kv.status}.",
        })

        get_kv_data = case get_kv.status
          when 200
            kv_data = JSON.parse(get_kv.body)
            kv_data_count = kv_data.count

            Configrr::Log.debug({
              'consul_kv_count'  => kv_data_count,
              'consul_kv_prefix' => kv_prefix,
              'message'          => "Found #{kv_data_count} KV for consul prefix #{kv_prefix}.",
            })

            kv_data
          when 404
            Configrr::Log.error({
              'consul_error_code' => get_kv.status,
              'message'           => "Invalid Token or Non-existent prefix #{kv_prefix} used.",
            })
          else
            Configrr::Log.error({
              'consul_error_code' => get_kv.status,
              'message'           => get_kv,
            })
          end

      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, JSON::ParserError => e
        Configrr::Log.error e.message
      end

      get_kv_data
    end

  end
end
