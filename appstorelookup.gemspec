# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "appstorelookup"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["williamlocke"]
  s.date = "2013-12-10"
  s.description = "Looks up app store app information based on search terms, combined with unique app identifier such as bundleId or AppleId"
  s.email = "williamlocke@me.com"
  s.executables = ["appstorelookup"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/appstorelookup",
    "lib/appstorelookup.rb",
    "test/helper.rb",
    "test/test_appstorelookup.rb"
  ]
  s.homepage = "http://github.com/williamlocke/appstorelookup"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Search app store meta data."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_runtime_dependency(%q<appfigures>, [">= 0"])
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_runtime_dependency(%q<table_print>, [">= 0"])
      s.add_runtime_dependency(%q<atomic>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_dependency(%q<appfigures>, [">= 0"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<table_print>, [">= 0"])
      s.add_dependency(%q<atomic>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.2.0"])
    s.add_dependency(%q<appfigures>, [">= 0"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<table_print>, [">= 0"])
    s.add_dependency(%q<atomic>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

