class ServiceResult < Data.define(:success, :data, :error, :code, :meta)
  EMPTY_META = {}.freeze

  def self.success(data = nil, code: :ok, meta: {})
    new(success: true, data: data, code: code, meta: meta)
  end

  def self.failure(error, code: :unprocessable_entity, meta: {})
    new(success: false, error: error, code: code, meta: meta)
  end

  def initialize(success:, data: nil, error: nil, code: :ok, meta: EMPTY_META)
    super(
      success: success,
      data:    data,
      error:   error,
      code:    code,
      meta:    (meta || EMPTY_META).freeze
    )
  end

  def success? = success
  def failure? = !success

  def on_success
    yield(data) if success? && block_given?
    self
  end

  def on_failure
    yield(error, code) if failure? && block_given?
    self
  end
end
