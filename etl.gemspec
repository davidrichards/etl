# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{etl}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Richards"]
  s.date = %q{2009-08-03}
  s.default_executable = %q{etl}
  s.description = %q{A basic ETL utility to make extract, transform, and load projects simpler, logged, and sharable}
  s.email = %q{davidlamontrichards@gmail.com}
  s.executables = ["etl"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/etl", "lib/all.rb", "lib/etl", "lib/etl/active_record_loader.rb", "lib/etl/bucket.rb", "lib/etl/csv_et.rb", "lib/etl/etl.rb", "lib/etl/time_bucket.rb", "lib/etl/xml_et.rb", "lib/etl.rb", "lib/helpers", "lib/helpers/array.rb", "lib/helpers/observation.rb", "lib/helpers/open_struct.rb", "lib/helpers/string.rb", "lib/helpers/symbol.rb", "spec/etl", "spec/etl/bucket_spec.rb", "spec/etl/csv_et_spec.rb", "spec/etl/etl_spec.rb", "spec/etl/xml_et_spec.rb", "spec/etl_spec.rb", "spec/fixtures", "spec/fixtures/test_file.csv", "spec/helpers", "spec/helpers/array_spec.rb", "spec/helpers/observation_spec.rb", "spec/helpers/open_struct_spec.rb", "spec/helpers/string_spec.rb", "spec/helpers/symbol_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/davidrichards/etl}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A basic ETL utility to make extract, transform, and load projects simpler, logged, and sharable}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<log4r>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<log4r>, [">= 0"])
  end
end
