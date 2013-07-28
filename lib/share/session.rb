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
        document = create(@current_document, message.type)
        response[:create] = true
        response[:meta] = document.meta
      elsif document.nil?
        response[:error] = "Document does not exist"
      end

      if message.operation?
        submit_op(@current_document, message)
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

    private

    def create(document_id, type)
      meta = {}
      meta[:creator] = @name if @name
      meta[:ctime] = meta[:mtime] = Time.now
      # TODO: documents should store metadata
      #@repo.create(document_id, meta, type)
      @repo.create(document_id, type)
    end

    def submit_op(document_id, message)
      # TODO: operations should store metadata
      if operation
        doc = @get.get(document_id)
        doc.apply_op(message.version, message.operation)
      end
    end

  end
end
