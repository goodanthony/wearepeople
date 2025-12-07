class ApplicationService
  class ContractError       < StandardError; end
  class ServiceFailureError < StandardError; end

  FILTER = ActiveSupport::ParameterFilter.new(
    Rails.application.config.filter_parameters
  )

  # -------------------------------------------------------------------------
  # 1. Safe Mode: .call
  # -------------------------------------------------------------------------
  # Use this when you want to HANDLE the failure manually (e.g., in Controllers).
  #
  # Returns: ServiceResult (success? or failure?)
  #
  # Usage:
  #   def create
  #     result = CreateOrder.call(params)
  #     if result.success?
  #       redirect_to result.data
  #     else
  #       render :new, status: :unprocessable_entity
  #     end
  #   end
  def self.call(*args, **kwargs, &block)
    around_call(args, kwargs) do
      service = new(*args, **kwargs, &block)
      result  = service.call

      unless result.is_a?(ServiceResult)
        raise ContractError, "#{name}#call must return a ServiceResult. Got: #{result.class}"
      end

      result
    end
  end

  # -------------------------------------------------------------------------
  # 2. Bang Mode: .call!
  # -------------------------------------------------------------------------
  # Use this when you want the system to HALT or RETRY on failure.
  #
  # Returns: ServiceResult (on success only)
  # Raises:  ServiceFailureError (on failure)
  #
  # Usage A: Background Jobs (Triggers Active Job 'retry_on')
  #   def perform(id)
  #     ProcessImage.call!(id: id)
  #   end
  #
  # Usage B: Database Transactions (Triggers Rollback)
  #   ActiveRecord::Base.transaction do
  #     user = CreateUser.call!(params)
  #     SendWelcomeEmail.call!(user: user)
  #   end

  def self.call!(*args, **kwargs, &block)
    result = call(*args, **kwargs, &block)

    # NOTE: this raise is outside around_call
    unless result.success?
      raise ServiceFailureError, "Service failed: #{result.error} | Meta: #{result.meta.inspect}"
    end

    result
  end

  def self.around_call(args, kwargs)
    yield
  rescue ServiceFailureError
    # expected logical failures raised inside #call – don't send to Sentry here
    raise
  rescue StandardError => e
    safe_params = FILTER.filter({ args: args, kwargs: kwargs })

    Sentry.capture_exception(
      e,
      extra: { service: name, params: safe_params }
    )

    raise
  end

  private

    def success(data = nil, code: :ok, meta: {})
      ServiceResult.success(data, code: code, meta: meta)
    end

    def failure(error, code: :unprocessable_entity, meta: {})
      ServiceResult.failure(error, code: code, meta: meta)
    end
end
