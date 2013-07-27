module Share
  class UnexpectedVersionError < ArgumentError; end

  class Document
    attr_reader :id

    def initialize(id)
      @id = id
      @ops = []
      @type = Share::Types::Text.new
    end

    def version
      @ops.size
    end

    def apply_op(to_version, op)
      raise UnexpectedVersionError if to_version > self.version

      transforming_ops = if to_version == self.version
                           []
                         else
                           get_ops(to_version, self.version)
                         end
      transforming_ops.each do |t_op|
        op = @type.transform([op], [t_op], 'left').first
      end

      @ops << op
    end

    # return the current value of the document after all operations
    def snapshot
      value = ""
      @ops.each do |op|
        value = apply(value, op)
      end
      value
    end

    private

    def get_ops(from_version, to_version)
      unless to_version.to_i > from_version.to_i
        raise ArgumentError, "to_version must be higher than from_version"
      end
      @ops[from_version.to_i, to_version.to_i - from_version.to_i]
    end

    def apply(str, op)
      @type.apply(str,[op])
    end

  end
end
