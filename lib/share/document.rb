module Share
  class Document
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def version
      0
    end
  end
end

