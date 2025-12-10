# Base presenter class used across the application for JSON rendering.
#
# Goals:
# - Provide a single, consistent contract: `Presenter.new(record, actor:, context:).as_json`
# - Be reusable for both internal React JSON and external API responses.
# - Keep logic for "who can see what" (via `actor`) and "extra fields" (via `context`)
#   out of controllers and views.
#
# Usage:
#   json = LocationPresenter.new(location, actor: current_user).as_json
#   json = LocationPresenter.collection(locations, actor: current_user, context: { include: [:internal] })
#
# Conventions:
# - `record` is the underlying model or PORO.
# - `actor` is the entity requesting the data (e.g. User, Location, Service) and is used
#   for permissions / tiering decisions in subclasses.
# - `context` is a free-form hash for flags such as `include: [:internal, :debug]`.
class ApplicationPresenter
  # Frozen hash to avoid allocating a new empty hash on every instantiation
  EMPTY_CONTEXT = {}.freeze

  attr_reader :record, :actor, :context

  # @param record [Object] The model instance being presented.
  # @param actor [Object, nil] The entity requesting the data (for permissions / tiering).
  # @param context [Hash, nil] Extra data (e.g. includes, feature flags).
  def initialize(record, actor: nil, context: nil)
    @record  = record
    @actor   = actor
    @context = context || EMPTY_CONTEXT
  end

  # Entry point used by Rails / callers when rendering JSON.
  def as_json(*)
    attributes
  end

  # Handy when something expects a Hash instead of as_json.
  def to_h
    attributes
  end

  # Subclasses must implement this and return a Hash.
  def attributes
    raise NotImplementedError, "#{self.class.name} must implement #attributes"
  end

  # Helper for serialising collections of records with the same presenter.
  #
  # Example:
  #   LeadPresenter.collection(leads, actor: current_user, context: { include: [:internal] })
  #
  # `context[:include]` is normalised once here for performance, then reused in each instance.
  def self.collection(records, actor: nil, context: nil)
    if context && context[:include].present?
      context = context.dup
      context[:include] = normalize_includes(context[:include])
    end

    records.map { |record| new(record, actor: actor, context: context).as_json }
  end

  # Always work with a frozen Array<Symbol> for fast include? checks.
  #
  # This is intentionally public (class-level) so instances can call it directly
  # without using `send` or duplicating logic.
  #
  # @param raw_includes [Array<String,Symbol>, Symbol, String]
  # @return [Array<Symbol>] frozen array of symbols
  def self.normalize_includes(raw_includes)
    Array(raw_includes).map { |k| k.to_sym }.freeze
  end

  private

    # Check whether a given include flag was requested.
    #
    # Used by subclasses to conditionally expose extra fields:
    #   data[:internal_notes] = record.internal_notes if include?(:internal)
    #
    # If no includes are present, this is a very cheap check and does nothing.
    def include?(key)
      return false if key.nil? || context[:include].nil?

      @includes ||= self.class.normalize_includes(context[:include])
      @includes.include?(key.to_sym)
    end
end
