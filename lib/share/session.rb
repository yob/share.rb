require 'securerandom'

module Share
  class Session
    attr_reader :id

    def initialize(data, repo)
      @id = SecureRandom.hex
      @connect_time = Time.now()
      @headers = data[:headers]
      @remote_address = data[:remote_address]
      @repo = repo

      @listeners = {}
      @name = nil
    end

    def handle_message(message)
      return if message.auth?

      # This got yucky fast.
      message.document and @current_document = message.document

      response = {doc: @current_document}

      document = @repo.get(@current_document)

      if message.create? && document.exists?
        response[:create] = false
      elsif message.create?
        document = @session.create(@current_document, message.type, {})
        response[:create] = true
        response[:meta] = document.meta
      elsif !document.exists?
        response[:error] = "Document does not exist"
      end

      if message.operation?
        @session.submit_op(@current_document, message.data)
        return {v: message.data[:v]}
      end

      if document.type && message.type && document.type != message.type
        response[:error] = "Type mismatch"
      end

      if message.open? and response[:error]
        response[:open] = false
        return response
      end


      if message.open?
        @app.subscribe_to(@current_document, message.version)
        response[:open] = true
        response[:v] = document.version
      end

      if message.snapshot?
        response[:snapshot] = document.snapshot
      end

      if message.close?
        @app.unsubscribe_from(@current_document)
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
      action = Action.new({name: document_id, type: type, meta: meta}, 'create')
      authorize! action
      meta[:snapshot] = type::DEFAULT_VALUE.dup
      @repo.create(document_id, meta, type)
    end

    def submit_op(document_id, operation)
      operation[:meta] ||= {}
      operation[:meta][:source] = id
      dup_if_source = operation[:dup_if_source] || []
      if operation["op"]
        # action = Action.new({
        #   name: document.name, 
        #   type: document.type, 
        #   meta: operation[:meta], 
        #   v: operation["v"]},
        #   'submit op'
        # )
        # authorize! action
        @repo.apply_operation(document_id, operation[:v], operation[:op], operation[:meta], dup_if_source)
      else
        action = Action.new(
          {name: name, meta: operation[:meta]}, 'submit meta'
        )
        authorize! action
        @repo.apply_meta_operation!(name, operation)
      end
    end

    def authorize!(action)
      
    end

    def delete(adapter, name)
      action = Action.new({name: name}, 'delete')
      authorize! action
      adapter.delete!(name)
    end
  end
end
