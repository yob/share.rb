require "thread_safe"

module Share
  class Repo

    OPS_BEFORE_COMMIT = 20

    class DocExistsError < ArgumentError; end
    class UnsupportedTypeError < ArgumentError; end

    def initialize
      @documents = ThreadSafe::Hash.new
    end

    def get(document_id)
      document = @documents[document_id] # || load from DB
      #document.cancel_reap_timer
    end

    def create(id, type)
      if get(id).nil?
        @documents[id] = Share::Document.new(id, type_string_to_instance(type))
      else
        raise DocExistsError, "doc #{id} already exists"
      end
    end

    def get_snapshot(id)
      get(id).get_snapshot
    end

    def subscribe(id, at_version, listener)
      document = get(id)
      document.add_observer listener, :on_operation
    end

    def unsubscribe(id, listener)
      document = get(id)
      document.delete_observer listener
      return if document.count_observers > 0
      document.reap_timer { reap document }
    end

    # This got ugly
    def apply_operation(id, version, operation, meta={}, dup_if_source=[])
      document = get(id)
      document.synchronize do

        if document.version == version
          operations = []
        else
          operations = document.get_ops(document.version, version)

          unless document.version - version == operations.length
            # This should never happen. It indicates that we didn't get all the ops we
            # asked for. Its important that the submitted op is correctly transformed.
            raise 'Internal error'
          end
        end

        begin
          operations.each do |_operation|
            if _operation.meta[:source] &&
                _operation.dup_if_source &&
                _operation.dup_if_source.includes?(_operation.meta[:source])

              raise "Op alread submitted"
            end
            operation[:op] = document.type.transform operation[:op], _operation.op, 'left'
            operation[:v] += 1
          end
        end

        begin
          snapshot = document.type.apply document.snapshot, operation
        end

        unless version == document.version
          raise 'Internal error'
        end

        document.write_op(
          op: operation,
          v: version + 1,
          meta: meta
        )

        document.version = version + 1
        document.snapshot = snapshot
        document.notify_observers( v:version, op:operation, meta:meta )

        if document.comitted_version + OPS_BEFORE_COMMIT <= document.version
          data = {}
          data[:meta] = {mtime: Time.now}
          data[:v] = version
          data[:snapshot] = snapshot
          document.write_snapshot data, nil
        end
      end
    end

    def reap(id)
      documents.delete id
    end

    private

    def type_string_to_instance(str)
      case str
      when "text" then Share::Types::Text.new
      else
        raise UnsupportedTypeError, "Unsupported type '#{str}'"
      end
    end

  end
end
