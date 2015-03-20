# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'psdparser/version'

Gem::Specification.new do |spec|
  spec.name          = "psdparser"
  spec.version       = Psdparser::VERSION
  spec.date          = Time.now.strftime('%Y-%m-%d')
  
  spec.authors       = [""]
  spec.email         = [""]
  spec.summary       = %q{基于cherishpeace的psdparser修改}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.*','bin/*.*']
  spec.executables   = ["psdparser"]
  spec.require_paths = ["lib","bin"]
  spec.add_runtime_dependency "mustache", "~> 0.9"
  spec.add_runtime_dependency "psd", "~> 3.1"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  
end
