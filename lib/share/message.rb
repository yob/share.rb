require 'json'

module Share
  class ProtocolError < StandardError; end

  class Message

    attr_reader :data

    def initialize(raw_data)
      raw_hash = JSON.parse(raw_data)
      @data = {}
      raw_hash.each do |key, value|
        @data[key.to_sym] = value
      end
      validate!
    end

    def to_s
      "<#{self.class} #{@data} >"
    end

    alias inspect to_s

    def document
      @data[:doc]
    end

    def type
      @data[:type]
    end

    def create?
      @data[:create]
    end

    def snapshot?
      @data.key?(:snapshot) && @data[:snapshot] == nil
    end

    def open?
      @data[:open] == true
    end

    def close?
      @data[:open] == false
    end

    def auth?
      @data.has_key?(:auth)
    end

    def operation?
      operation
    end

    def operation
      @data[:op]
    end

    def version
      @data[:v]
    end

    private

    def validate!
      if (operation? || close?) && ( create? || snapshot? || open? )
        raise ProtocolError.new \
          ["Bad combination of message properties.", @data.inspect]
      end

      if create? && !type
        raise ProtocolError.new \
          ["Bad or missing type when creating document.", @data.inspect]
      end
    end

  end
end
