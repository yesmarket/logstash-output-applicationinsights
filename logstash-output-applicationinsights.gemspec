Gem::Specification.new do |s|
  s.name          = 'logstash-output-applicationinsights'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash output plugin for Microsoft Azure Application Insights.'
  s.description   = 'Logstash output plugin to send metrics to Microsoft Azure Application Insights. Makes HTTP requests to Application Insights API for custom events and metrics.'
  s.homepage      = 'https://github.com/yesmarket/logstash-output-applicationinsights'
  s.authors       = ['Ryan Bartsch']
  s.email         = 'rbartsch@adam.com.au'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "rest-client", "~> 2.0"
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "logstash-codec-plain", "~> 3.0"
  s.add_development_dependency "logstash-devutils", "~> 1.3"
end
