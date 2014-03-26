# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "freshbooks.rb"
  s.version = "3.0.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Curren"]
  s.date = "2014-02-13"
  s.description = ""
  s.email = ["ben@thecurrens.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.md"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.md", "Rakefile", "freshbooks.rb.gemspec", "lib/freshbooks.rb", "lib/freshbooks/address.rb", "lib/freshbooks/api.rb", "lib/freshbooks/autobill.rb", "lib/freshbooks/base.rb", "lib/freshbooks/budget.rb", "lib/freshbooks/callback.rb", "lib/freshbooks/card.rb", "lib/freshbooks/category.rb", "lib/freshbooks/client.rb", "lib/freshbooks/connection.rb", "lib/freshbooks/contact.rb", "lib/freshbooks/credits.rb", "lib/freshbooks/estimate.rb", "lib/freshbooks/expense.rb", "lib/freshbooks/expiration.rb", "lib/freshbooks/gateway.rb", "lib/freshbooks/gateway_transaction.rb", "lib/freshbooks/invoice.rb", "lib/freshbooks/item.rb", "lib/freshbooks/language.rb", "lib/freshbooks/line.rb", "lib/freshbooks/links.rb", "lib/freshbooks/list_proxy.rb", "lib/freshbooks/payment.rb", "lib/freshbooks/project.rb", "lib/freshbooks/recurring.rb", "lib/freshbooks/response.rb", "lib/freshbooks/schema/definition.rb", "lib/freshbooks/schema/mixin.rb", "lib/freshbooks/staff.rb", "lib/freshbooks/system.rb", "lib/freshbooks/task.rb", "lib/freshbooks/tax.rb", "lib/freshbooks/time_entry.rb", "lib/freshbooks/xml_serializer.rb", "lib/freshbooks/xml_serializer/serializers.rb", "script/console", "script/destroy", "script/generate", "test/fixtures/freshbooks_credentials.sample.yml", "test/fixtures/freshbooks_credentials.yml", "test/fixtures/invoice_create_response.xml", "test/fixtures/invoice_get_response.xml", "test/fixtures/invoice_list_response.xml", "test/fixtures/recurring_create_response.xml", "test/fixtures/recurring_get_response.xml", "test/fixtures/recurring_list_response.xml", "test/fixtures/success_response.xml", "test/live_connection_test.rb", "test/mock_connection.rb", "test/schema/test_definition.rb", "test/schema/test_mixin.rb", "test/test_base.rb", "test/test_connection.rb", "test/test_helper.rb", "test/test_invoice.rb", "test/test_list_proxy.rb", "test/test_page.rb", "test/test_recurring.rb", ".gemtest"]
  s.homepage = "https://github.com/bcurren/freshbooks.rb"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "freshbooks.rb"
  s.rubygems_version = "2.0.14"
  s.summary = ""
  s.test_files = ["test/schema/test_definition.rb", "test/schema/test_mixin.rb", "test/test_base.rb", "test/test_connection.rb", "test/test_helper.rb", "test/test_invoice.rb", "test/test_list_proxy.rb", "test/test_page.rb", "test/test_recurring.rb", "test/live_connection_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_development_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.4"])
      s.add_development_dependency(%q<hoe>, ["~> 3.9"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_dependency(%q<mocha>, [">= 0.9.4"])
      s.add_dependency(%q<hoe>, ["~> 3.9"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<newgem>, [">= 1.5.3"])
    s.add_dependency(%q<mocha>, [">= 0.9.4"])
    s.add_dependency(%q<hoe>, ["~> 3.9"])
  end
end
