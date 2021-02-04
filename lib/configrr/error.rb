module Configrr
  module Error
    class BaseError < StandardError
      def initialize msg = 'Base Error'
        super
      end
    end

    class ConfigENOENT < BaseError; end
  end
end
