# -*- encoding: utf-8 -*-
require File.expand_path('../lib/db_importer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ralph von der Heyden']
  gem.email         = ['ralph@rvdh.de']
  gem.description   = %q{Import databases}
  gem.summary       = %q{Import databases}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'db_importer'
  gem.require_paths = ['lib']
  gem.version       = DbImporter::VERSION
  gem.add_development_dependency 'rake'
  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'cocaine'
end
