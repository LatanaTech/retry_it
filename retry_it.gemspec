
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "retry_it/version"

Gem::Specification.new do |spec|
  spec.name          = "retry_it"
  spec.version       = RetryIt::VERSION
  spec.authors       = ["rgould"]
  spec.email         = ["richard.gould@daliaresearch.com"]

  spec.summary       = %q{Easily retry code that fails intermittently}
  spec.description   = %q{Easily retry code that fails intermittently. Perfect for interacting with that flakey HTTP API.}
  spec.homepage      = "https://github.com/DaliaResearch/retry_it"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
