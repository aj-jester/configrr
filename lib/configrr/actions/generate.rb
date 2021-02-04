require 'digest'
require 'erb'
require 'json'

module Configrr::Actions
  module Generate

    def self.render_erb

      start_time = Time.now.to_i

      foreman_hosts   = Configrr::Hosts.foreman_hosts
      agentless_hosts = Configrr::Hosts.agentless_hosts

      render_time = Time.now.to_f * 1000
      restart_services = Array.new

      Configrr::Config.get['templates'].each do |template, param|

        unless File.file? param['ingress']
          Configrr::Log.info "File for template #{template} not found, skipping."
          next
        end

        Configrr::Log.debug ({
          'rendering_template' => template,
          'message'  => "Rendering template #{template}",
        })

        old_sha = File.file?(param['egress']) ? Digest::SHA2.file(param['egress']).hexdigest : nil

        File.open(param['egress'], 'w') do |f|
          f.write(ERB.new(IO.read(param['ingress']), 0, '>').result(binding))
        end

        new_sha = Digest::SHA2.file(param['egress']).hexdigest

        if old_sha != new_sha

          Configrr::Log.info "#{template} template updated."

          Configrr::Log.debug ({
            'template' => template,
            'old_sha'  => old_sha,
            'new_sha'  => new_sha,
          })

          unless param['restart'].nil?
            restart_services += [param['restart']]
            Configrr::Log.debug "Restarting service due to #{template} template."
          end
        end

      end

      render_time = (Time.now.to_f * 1000 - render_time).round(2)

      restart_services.uniq!
      total_restarts = restart_services.size

      if restart_services.any?
        Configrr::Log.info ({
          'restart_services' => restart_services,
          'total_restarts'   => total_restarts,
          'message'          => "Restarting #{total_restarts} service#{total_restarts == 1 ? '' : 's'}"
        })

        restart_services.map do |service|
          Configrr::Exec.cmd service
        end
      else
        Configrr::Log.info ({
          'total_restarts' => total_restarts,
          'message'        => "#{total_restarts} services restarted.",
        })
      end

      end_time = Time.now.to_i

      total_time = end_time - start_time

      configrr_state = {
        'start_time_s'     => start_time,
        'end_time_s'       => end_time,
        'total_time_s'     => total_time,
        'render_time_ms'   => render_time,
        'restart_services' => restart_services,
        'total_restarts'   => total_restarts,
        'state_file_path'  => Configrr::Config.get['state_file_path'],
      }

      default_state_file_path = '/var/tmp/configrr_state.json'

      if Configrr::Config.get['state_file_path'].nil?

        configrr_state['state_file_status'] = 'config does not exist'

        File.open(default_state_file_path,'w') do |f|
          f.write(configrr_state.to_json)
        end

      else

        begin

          configrr_state['state_file_status'] = 'state file does exist'

          File.open(Configrr::Config.get['state_file_path'],'w') do |f|
            f.write(configrr_state.to_json)
          end

          if default_state_file_path != Configrr::Config.get['state_file_path'] && File.file?(default_state_file_path)
            File.delete(default_state_file_path)
          end

        rescue Errno::ENOENT

          configrr_state['state_file_status'] = 'state file does not exist'

          File.open(default_state_file_path,'w') do |f|
            f.write(configrr_state.to_json)
          end
        end
     
      end

      Configrr::Log.info ({
        'render_time' => render_time,
        'total_time'  => total_time,
        'message'     => "Render: #{render_time}ms. Total: #{total_time}s.",
      })

    end

    def self.run
      self.render_erb
    end

  end
end
