require 'securerandom'

module Share
  class Session
    attr_reader :id

    def initialize(repo)
      @id = SecureRandom.hex
      @connect_time = Time.now
      # TODO record the current users details
      # @headers = data[:headers]
      # @remote_address = data[:remote_address]
      @repo = repo

      @current_document = nil
      @listeners = {}
      @name = nil
    end

    def handle_message(message)
      return if message.auth?

      @current_document = message.document if message.document

      response = {doc: @current_document}

      document = @repo.get(@current_document)

      if message.create? && document
        response[:create] = false
      elsif message.create?
        document = @repo.create(@current_document, message.type)
        response[:create] = true
        response[:meta] = document.meta
      elsif document.nil?
        response[:error] = "Document does not exist"
      end

      if message.operation?
        @session.submit_op(@current_document, message.data)
        return {v: message.data[:v]}
      end

      if document && document.type && message.type && document.type != message.type
        response[:error] = "Type mismatch"
      end

      if message.open? and response[:error]
        response[:open] = false
        return response
      end


      if message.open?
        #@app.subscribe_to(@current_document, message.version)
        response[:open] = true
        response[:v] = document.version
      end

      if document && message.snapshot?
        response[:snapshot] = document.snapshot
      end

      if message.close?
        #@app.unsubscribe_from(@current_document)
        response = {doc: @current_document, open: false}
      end

      response
    end

    def create(document_id, type, meta)
      type = TYPE_MAP[type] if type.is_a?(String)
      meta = {}
      meta[:creator] = @name if @name
      meta[:ctime] = meta[:mtime] = Time.now()
      meta[:v] = 0
      meta[:snapshot] = type::DEFAULT_VALUE.dup
      @repo.create(document_id, meta, type)
    end

    def submit_op(document_id, operation)
      operation[:meta] ||= {}
      operation[:meta][:source] = id
      dup_if_source = operation[:dup_if_source] || []
      if operation["op"]
        @repo.apply_operation(document_id, operation[:v], operation[:op], operation[:meta], dup_if_source)
      else
        @repo.apply_meta_operation!(name, operation)
      end
    end

    def delete(adapter, name)
      adapter.delete!(name)
    end
  end
end
