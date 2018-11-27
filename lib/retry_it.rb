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
      if retries < max_runs && (!should_retry_proc.is_a?(Proc) || should_retry_proc.call(e))
        if logger
          logger.info "Error (#{e.class}), retrying ##{retries} of #{max_runs}. Sleeping for #{timeout}"
        end
        if on_error && on_error.is_a?(Proc)
          on_error.call e
        end
        if timeout > 0
          sleep timeout
        end
        retry
      else
        raise
      end
    end
  end

end
