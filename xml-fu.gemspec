# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xml-fu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "xml-fu"
  gem.version       = XmlFu::VERSION
  gem.authors       = ["Ryan Johnson"]
  gem.email         = ["rhino.citguy@gmail.com"]
  gem.homepage      = "http://github.com/CITguy/#{gem.name}"
  gem.summary       = %q{Simple Hash/Array to XML generation}
  gem.license       = 'MIT'
  gem.description   = %q{
    Inspired by the Gyoku gem for hash to xml conversion,
    XmlFu is designed to require no meta tagging for
    node attributes and content. (i.e. no :attributes! and no :order!)
  }

  gem.rubyforge_project = 'xml-fu'

  gem.add_dependency "builder", ">= 2.1.2"

  gem.add_development_dependency "rspec", ">= 2.4.0"
  gem.add_development_dependency "rake"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
