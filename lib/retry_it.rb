require "retry_it/version"

module RetryIt
  MAX_RUNS = 10
  DEFAULT_TIMEOUT_S = 10 # seconds
  DEFAULT_EXCEPTIONS = []

  def retry_it(max_runs: MAX_RUNS,
               errors: DEFAULT_EXCEPTIONS,
               on_error: nil,
               timeout: DEFAULT_TIMEOUT_S,
               should_retry_proc: nil,
               logger: nil)
    retries = 0
    begin
      yield
    rescue *errors => e
      retries += 1
      should_retry_proc_result = should_retry_proc.respond_to?(:call) ? should_retry_proc.call(e) : true

      if retries < max_runs && should_retry_proc_result
        if logger
          logger.info "Error (#{e.class}), retrying ##{retries} of #{max_runs}. Sleeping for #{timeout}"
        end

        on_error.call(e) if on_error && on_error.respond_to?(:call)
        sleep timeout if timeout > 0

        retry
      else
        raise
      end
    end
  end

end
