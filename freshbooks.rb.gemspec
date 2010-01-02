# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tedkulp-freshbooks.rb}
  s.version = "3.0.19"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Curren"]
  s.date = %q{2009-07-16}
  s.description = %q{FreshBooks.rb is a Ruby interface to the FreshBooks API. It exposes easy-to-use classes and methods for interacting with your FreshBooks account.}
  s.email = ["ben@outright.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README", "Rakefile", "lib/freshbooks.rb", "lib/freshbooks/base.rb", "lib/freshbooks/category.rb", "lib/freshbooks/client.rb", "lib/freshbooks/connection.rb", "lib/freshbooks/estimate.rb", "lib/freshbooks/expense.rb", "lib/freshbooks/invoice.rb", "lib/freshbooks/item.rb", "lib/freshbooks/line.rb", "lib/freshbooks/links.rb", "lib/freshbooks/list_proxy.rb", "lib/freshbooks/payment.rb", "lib/freshbooks/project.rb", "lib/freshbooks/recurring.rb", "lib/freshbooks/response.rb", "lib/freshbooks/schema/definition.rb", "lib/freshbooks/schema/mixin.rb", "lib/freshbooks/staff.rb", "lib/freshbooks/task.rb", "lib/freshbooks/time_entry.rb", "lib/freshbooks/xml_serializer.rb", "lib/freshbooks/xml_serializer/serializers.rb", "script/console", "script/destroy", "script/generate", "test/fixtures/freshbooks_credentials.sample.yml", "test/fixtures/invoice_create_response.xml", "test/fixtures/invoice_get_response.xml", "test/fixtures/invoice_list_response.xml", "test/fixtures/success_response.xml", "test/mock_connection.rb", "test/schema/test_definition.rb", "test/schema/test_mixin.rb", "test/test_base.rb", "test/test_connection.rb", "test/test_helper.rb", "test/test_invoice.rb", "test/test_list_proxy.rb", "test/test_page.rb"]
  s.has_rdoc = true
  s.homepage = %q{}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{freshbooks.rb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{}
  s.test_files = ["test/schema/test_definition.rb", "test/schema/test_mixin.rb", "test/test_base.rb", "test/test_connection.rb", "test/test_helper.rb", "test/test_invoice.rb", "test/test_list_proxy.rb", "test/test_page.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.4"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<mocha>, [">= 0.9.4"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<mocha>, [">= 0.9.4"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
