# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mysql_cli/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ralph von der Heyden']
  gem.email         = ['ralph@rvdh.de']
  gem.description   = %q{Talk to Mysql databases via mysql cli tool}
  gem.summary       = %q{Talk to Mysql databases via mysql cli tool}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'mysql_cli'
  gem.require_paths = ['lib']
  gem.version       = MysqlCli::VERSION
  gem.add_development_dependency 'rake'
  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'cocaine'
end
