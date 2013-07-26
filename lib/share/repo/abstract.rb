module Share
  module Repo
    class Abstract

      OPS_BEFORE_COMMIT = 20

      attr_reader :adapter

      class MissingAdapterError < ArgumentError; end

      def initialize(options = {})
        unless options[:adapter] && options[:adapter] < Share::Adapter::Abstract::Document
          raise MissingAdapterError.new
        end

        @adapter = options[:adapter]
        @documents = ThreadSafe::Hash.new
      end

      def get(document_id)
        document = @documents[document_id] ||= begin
          @adapter.new(document_id)
        end
        document.cancel_reap_timer
        document
      end

      def create(id, data, type)
        get(id).create(data, type)
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
    end
  end
end
