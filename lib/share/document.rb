module Share
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
      @ops << op
    end
  end
end

