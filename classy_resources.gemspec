# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{classy_resources}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Golick","Justin Lynn"]
  s.date = %q{2009-11-16}
  s.description = %q{Instant ActiveResource compatible resources for sinatra.}
  s.email = %q{justinlynn@gmail.com}
  s.files = ["README.rdoc", "VERSION.yml", "lib/classy_resources", "lib/classy_resources/active_record.rb", "lib/classy_resources/mime_type.rb", "lib/classy_resources/post_body_param_parsing.rb", "lib/classy_resources/post_body_params.rb", "lib/classy_resources/sequel.rb", "lib/classy_resources/sequel_errors_to_xml.rb", "lib/classy_resources.rb", "test/active_record_test.rb", "test/fixtures", "test/fixtures/active_record_test_app.rb", "test/fixtures/sequel_test_app.rb", "test/sequel_errors_to_xml_test.rb", "test/sequel_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/justinlynn/classy_resources}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Instant ActiveResource or datamapper compatible resources. Think resource_controller, for sinatra. }

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.5"])
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<dm-serializer>, ["~> 1.0.2"])
      
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.5"])
      s.add_dependency(%q<sinatra>, ["~> 1.1.0"])
      s.add_dependency(%q<dm-serializer>, ["~> 1.0.2"])
      
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.5"])
    s.add_dependency(%q<sinatra>, ["~> 1.1.0"])
    s.add_dependency(%q<dm-serializer>, ["~> 1.0.2"])
    
  end
end
