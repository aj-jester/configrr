require 'json'
require 'logger'

module Configrr
  module Log

    def self.clogger
      if @clog.nil?
       @clog = Logger.new(Configrr::Config.get['logger']['file_path'],
                         'daily',
                          Configrr::Config.get['logger']['max_days'])
        @clog.formatter = JSONFormatter.new
      end

      @clog
    end

    def self.info msg
      self.clogger.info msg
    end

    def self.debug msg
      self.clogger.debug msg if Configrr::Config.get['logger']['debug']
    end

    def self.error msg, exit_on_error = true
      self.clogger.error msg
      exit 1 if exit_on_error
    end

  end
end

class JSONFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    {
      'timestamp' => time,
      'severity'  => severity,
      'content'   => msg,
    }.to_json + "\n"
  end
end
