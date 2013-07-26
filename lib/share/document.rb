module Share
  class StaleVersionError < ArgumentError; end
  class FailedOperationError < RuntimeError; end

  class Document
    attr_reader :id, :value

    def initialize(id)
      @id = id
      @ops = []
      @value = ""
    end

    def version
      @ops.size
    end

    def apply_op(to_version, op)
      raise StaleVersionError unless to_version == self.version

      new_val = apply(@value, op)
      if new_val
        @ops << op
        @value = new_val
      else
        raise FailedOperationError, "could not apply operation"
      end
    end

    private

  end
end

