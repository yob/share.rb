
module Share
  class Operation
    attr_reader :meta
    attr_accessor :op

    def initialize(op, meta = {})
      @op = op
      @meta = meta
    end
  end
end
