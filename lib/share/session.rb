require 'securerandom'

module Share
  class Session
    attr_reader :id

    def initialize(repo, app = nil)
      @id = SecureRandom.hex
      @connect_time = Time.now
      # TODO record the current users details
      # @headers = data[:headers]
      # @remote_address = data[:remote_address]
      @repo = repo

      @current_document = nil
      @observers = [app].compact
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

      if message.open? && response[:error]
        response[:open] = false
        return response
      end

      if message.open?
        document.add_observer(self)
        response[:open] = true
        response[:v] = document.version
      end

      if document && message.snapshot?
        response[:snapshot] = document.snapshot
      end

      if message.close?
        document.delete_observer(self)
        response = {doc: @current_document, open: false}
      end

      response
    end

    # first response sent to the client after they connect
    #
    def handshake_response
      {auth: @id}
    end

    # Call by documents to notify other users of new operations
    #
    def on_operation(doc_id, version, operation)
      # TODO skip notifying if the operation was made by this session
      # return if operation[:meta] && operation[:meta]["source"] == @session.id
      @current_document = doc_id if @current_document != doc_id
      @observers.each do |observer|
        response = {
          doc: @current_document,
          v: version,
          op: operation,
        }
        observer.on_operation(response)
      end
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
      doc = @repo.get(document_id)
      doc.apply_op(message.version, message.operation)
    end

  end
end
