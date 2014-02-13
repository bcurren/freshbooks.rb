%w[rubygems rake rake/clean fileutils rubigen hoe].each { |f| require f }
require File.dirname(__FILE__) + '/lib/freshbooks'

Hoe.plugin :newgem
Hoe.plugin :gemcutter

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('freshbooks.rb') do |p|
  p.developer('Ben Curren', 'ben@thecurrens.com')
  p.summary              = ''
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.readme_file          = "README.md"
  p.rubyforge_name       = p.name
  p.extra_deps           = [ ['activesupport', '>= 3.0.0'] ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    ['mocha', ">= 0.9.4"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
end
