Pod::Spec.new do |s|

  s.name         = "Polymorph"
  s.version      = "1.0.6"
  s.summary      = "Transform value of dictionary to property of Objective-C class."
  s.description  = <<-DESC
  Transform value of dictionary to property of Objective-C class, by using a
  `@dynamic` like directive.
  DESC
  s.homepage     = "https://github.com/douban/Polymorph"
  s.author       = { "Tony Li" => "crazygemini.lee@gmail.com" }
  s.source       = { :git => "https://github.com/douban/Polymorph.git",
                     :tag => "v#{s.version}" }
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.source_files = "Polymorph/**/*.{h,m}"
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.dependency "libextobjc/EXTScope", "~> 0.4"
  s.dependency "libextobjc/RuntimeExtensions", "~> 0.4"

end
