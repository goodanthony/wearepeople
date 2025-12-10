class ApplicationPresenter
  attr_reader :record, :actor, :context

  # @param record [Object] The model instance
  # @param actor [User, Location, nil] The entity requesting the data (for permissions)
  # @param context [Hash] Extra data (e.g., includes, feature flags)
  def initialize(record, actor: nil, context: {})
    @record  = record
    @actor   = actor
    @context = context || {}
  end

  def as_json(*)
    attributes
  end

  # For when something expects a Hash instead of as_json
  def to_h
    attributes
  end

  def attributes
    raise NotImplementedError, "#{self.class.name} must implement #attributes"
  end

  def self.collection(records, actor: nil, context: {})
    records.map { |record| new(record, actor: actor, context: context).as_json }
  end

  private

    # Normalise include keys to symbols so callers can pass strings or symbols
    def include?(key)
      includes = Array(context[:include]).map { |k| k.respond_to?(:to_sym) ? k.to_sym : k }
      includes.include?(key.respond_to?(:to_sym) ? key.to_sym : key)
    end
end
