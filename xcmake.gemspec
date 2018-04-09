lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xcmake/version"

Gem::Specification.new do |spec|
  spec.name          = "xcmake"
  spec.version       = Xcmake::VERSION
  spec.authors       = ["k-motoyan"]
  spec.email         = ["k.motoyan888@gmail.com"]

  spec.summary       = "Xcode resource genetator for command line."
  spec.description   = ""
  spec.homepage      = "https://github.com/k-motoyan/xcmake"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "xcodeproj", "~> 1.5.7"
  spec.add_dependency "thor", "~> 0.20.0"
  spec.add_dependency "colorize", "~> 0.8.1"

  spec.add_development_dependency "minitest", "~> 5.0"
end
