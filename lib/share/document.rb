require 'share/operation'

module Share
  class UnexpectedVersionError < ArgumentError; end
  class UnsupportedTypeError < ArgumentError; end

  # a single document that can be collaboratively edited
  #
  class Document
    attr_reader :id, :type

    def initialize(id, type = nil)
      @id = id
      @ops = []
      @type = type || "text"
      @transformer = type_string_to_instance(@type)
      @observers = []
    end

    def version
      @ops.size
    end

    def meta
      {}
    end

    # TODO needs dup_if_source and metadata support
    def apply_op(to_version, op, meta = {})
      raise UnexpectedVersionError if to_version > self.version
      op = [op] unless op.is_a?(Array)
      operation = Share::Operation.new(op, meta)

      transforming_operations = if to_version == self.version
                                  []
                                else
                                  get_ops(to_version, self.version)
                                end
      transforming_operations.each do |t_operation|
        operation.op = @transformer.transform(operation.op, t_operation.op, 'left').first
      end

      @ops << operation
      notify_observers(self.version - 1, operation)
    end

    # return the value of the document at a given version. If no specific
    # version is requested the latest version will be returned.
    #
    def snapshot(at_version = nil)
      at_version ||= self.version
      ops = get_ops(0, at_version).map(&:op).flatten
      @transformer.apply(default_snapshot, ops)
    end

    # These are methods that were originally on Repo and will probably need to
    # be added here:
    #
    # * subscribe
    # * unsubscribe

    def add_observer(observer)
      @observers << observer
    end

    def delete_observer(observer)
      @observers.delete(observer)
    end

    private

    def notify_observers(version, operation)
      @observers.each do |observer|
        observer.on_operation(@id, version, operation)
      end
    end

    def get_ops(from_version, to_version)
      if from_version.to_i == to_version.to_i
        []
      elsif to_version.to_i > from_version.to_i
        @ops[from_version.to_i, to_version.to_i - from_version.to_i]
      else
        raise ArgumentError, "to_version must be higher than from_version"
      end
    end

    def type_string_to_instance(str)
      case str
      when "text" then Share::Types::Text.new
      when "json" then Share::Types::JSON.new
      else
        raise UnsupportedTypeError, "Unsupported type '#{str}'"
      end
    end

    def default_snapshot
      case @type
      when "text" then ""
      when "json" then nil
      else
        raise UnsupportedTypeError, "Unsupported type '#{@type}'"
      end
    end

  end
end
