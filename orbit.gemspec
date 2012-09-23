Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'orbit'
  s.version     = '0.8.0'
  s.authors     = ["Jeff McFadden"]
  s.email       = ["jeff@forgeapps.com"]
  s.homepage    = "http://github.com/jeffmcfadden/orbit"
  s.summary     = "A ruby gem for calculating satellite positional data."
  s.description = "A ruby gem for calculating satellite positional data and look angles, etc."

  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'
end