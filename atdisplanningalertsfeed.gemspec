# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "atdisplanningalertsfeed/version"

Gem::Specification.new do |spec|
  spec.name          = "atdisplanningalertsfeed"
  spec.version       = ATDISPlanningAlertsFeed::VERSION
  spec.authors       = ["Henare Degan\n"]
  spec.email         = ["henare.degan@gmail.com"]
  spec.summary       =
    "Saves development applications from ATDIS feeds into morph.io for PlanningAlerts"
  spec.homepage      = ""
  spec.license       = "GPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  # Because we're using "safe navigation"
  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency "atdis"
  spec.add_runtime_dependency "scraperwiki-morph"
end
