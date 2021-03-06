lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "share"
  s.version     = "0.0.5"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Collin Miller"]
  s.email       = ["collintmiller@gmail.com"]
  s.homepage    = "https://github.com/collintmiller/share.rb"
  s.summary     = "port of sharejs server to Ruby ( rack/thin )"
  s.description = "OT server for rack/rails applications. Includes JSON OT algorithms ported from ShareJS"

  s.required_ruby_version = "1.9.2"
  s.required_rubygems_version = ">= 1.3.6"
  s.files        = Dir.glob("{bin,lib}/**/*") #+ %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.require_path = 'lib'

  s.add_dependency "sinatra"
  s.add_dependency "thin", "~> 1.4.1"
  s.add_dependency "websocket-rack", "~> 0.4.0"
  s.add_dependency "thread_safe", "~> 0.0.3"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "ir_b"
end
