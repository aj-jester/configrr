require 'ostruct'

module Configrr
  module Opts
    def self.cli opts = @opts
      if @opts.nil?
        @opts = OpenStruct.new opts
      end
      @opts
    end
  end
end
