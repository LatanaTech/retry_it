# RetryIt

Easily retry a code block a set amount of times, before giving up. Useful for unreliable external I/O, such as accessing
HTTP servers that periodically throw errors, but are expected to work most of the time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'retry_it'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install retry_it

## Usage

Include RetryIt in your class:

```
class APIClient
  include RetryIt
end
```

You can then call `retry_it` when running code that fails intermittently:

```
class APIClient
  include RetryIt

  def get_data
    retry_it(errors: [Timeout::Error]) do
      HTTP.get('http://foo.com')
    end
  end
end
```

If `HTTP.get` throws an error, `retry_it` will wait a few seconds, and then try
again. It will repeat this a few times before eventually giving up, and raising
the last error it received.

`retry_it` accepts these arguments:

* `max_runs`: controls the maximum number of times the block should be fun.
              Defaults to RetryIt::MAX_RUNS
* `errors`: an Array of subclasses of Exception, which indicate which Exceptions
            are considered retryable.
* `timeout`: how many seconds we will wait between retries. Defaults to
             RetryIt::DEFAULT_TIMEOUT_S
* `logger`: A Logger object. If provided, when a retry occurs, an info-level
            message will be logged.
* `should_retry_proc`: A Proc that can be used to more finely control when a
                       retry occurs. The Proc is given one parameter: the
                       Exception object. The Proc must return a boolean value.
                       A true indicates that a retry should occur. Useful for
                       when it is sometimes desired to retry from an error, but
                       not always (For instance, an HTTP error with code 504 is
                       retryable, but a 404 probably isn't)

Examples:

```
# Retry only on HTTPErrors with code 504. All other errors will not trigger a
# retry.
retry_it(timeout: 60, errors: [HTTPError], should_retry_proc: Proc.new { |e| e.code == 504 }) do
  some_api_request
end


# Use a logger to be notified when a retry occurs:
require 'logger'

logger = Logger.new STDOUT
retry_it(max_runs: 100, timeout: 60, errors: [Error], logger: logger) do
  some_api_request
end
```

Keep in mind that you can pass methods as parameters using `method`:

```
class APIClient
  include RetryIt

  def download_data
    retry_it(should_retry_proc: method(:is_retryable), errors: [HTTPError]) do
      api.get("foo.com")
    end
  end

  def is_retryable(error)
    error.code == 504
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
