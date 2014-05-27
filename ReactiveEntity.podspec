Pod::Spec.new do |s|

  s.name         = "ReactiveEntity"
  s.version      = "0.0.6"
  s.summary      = "Reactive Entity is Memory-based ValueObject Library"

  s.description  = <<-DESC
                   Reactive Entity is Memory-based ValueObject Library
                   See. https://github.com/Limbate/ReactiveEntity
                   DESC

  s.homepage     = "https://github.com/Limbate/ReactiveEntity"
  s.license      = 'Apache License, version 2.0'

  s.author       = { "AOKI Yuuto" => "aoki@limbate.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/Limbate/ReactiveEntity.git", :tag => "0.0.6" }

  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'

  s.requires_arc = true

end
