module Share
  class StaleVersionError < ArgumentError; end

  class Document
    attr_reader :id

    def initialize(id)
      @id = id
      @ops = []
    end

    def version
      @ops.size
    end

    def apply_op(to_version, op)
      raise StaleVersionError unless to_version == self.version

      @ops << op
    end
  end
end

