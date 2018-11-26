require "test_helper"

class RetryItTest < Minitest::Test
  class Error < StandardError
    attr_reader :code
    def initialize(code = nil)
      @code = code
    end
  end

  include ::RetryIt

  def test_that_it_has_a_version_number
    refute_nil ::RetryIt::VERSION
  end

  def test_it_retries_until_giving_up
    times_run = 0
    assert_raises RuntimeError do
      retry_it(timeout: 0, errors: [RuntimeError]) do
        times_run += 1
        raise "Some kind of network timeout"
      end
    end
    assert_equal times_run, ::RetryIt::MAX_RUNS
  end

  def test_it_stops_retrying_on_success
    times_run = 0
    retry_it(timeout: 0, errors: [Error]) do
      times_run += 1
      if times_run == 1
        raise Error.new, "Some kind of network timeout"
      end
    end
    assert_equal times_run, 2
  end

  def test_it_supports_checking_errors
    assert_raises Error do
      retry_it(timeout: 0, errors: [Error], should_retry_proc: Proc.new { |e| e.code == 504 }) do
        raise Error.new(500), "Server Error"
      end
    end
    times_run = 0
    assert_raises Error do
      retry_it(timeout: 0, errors: [Error], should_retry_proc: Proc.new { |e| e.code == 504 }) do
        times_run += 1
        raise Error.new(504), "Server Error"
      end
    end
    assert_equal times_run, ::RetryIt::MAX_RUNS
  end

  def test_it_supports_logger
    logger = Minitest::Mock.new
    logger.expect :info, nil, [String]
    times_run = 0
    retry_it(timeout: 0, errors: [Error], logger: logger) do
      times_run += 1
      if times_run == 1
        raise Error.new, "Some kind of network timeout"
      end
    end
    assert_equal times_run, 2
  end

end
