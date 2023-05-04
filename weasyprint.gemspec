# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "weasyprint/version"

Gem::Specification.new do |s|
  s.name        = "weasyprint"
  s.version     = WeasyPrint::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jared Pace", "Relevance", "Simply Business"]
  s.email       = ["jared@codewordstudios.com", "lukas.oberhuber@simplybusiness.co.uk"]
  s.homepage    = "https://github.com/simplybusiness/weasyprint"
  s.summary     = "HTML+CSS -> PDF"
  s.description = "Uses weasyprint to create PDFs using HTML"

  # s.rubyforge_project = "weasyprint"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Developmnet Dependencies
  s.add_development_dependency(%q<activesupport>, [">= 3.0.8"])
  s.add_development_dependency(%q<mocha>, [">= 0.9.10"])
  s.add_development_dependency(%q<rack-test>, [">= 0.5.6"])
  s.add_development_dependency(%q<rake>, ["~>0.9.2"])
  s.add_development_dependency(%q<rdoc>, ["~> 4.0.1"])
  s.add_development_dependency(%q<rspec>, ["~> 3.10.0"])
end
