Pod::Spec.new do |spec|
  spec.name = 'Bluejay'
  spec.version = '0.8.11'
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.homepage = 'https://github.com/steamclock/bluejay'
  spec.authors = { 'Jeremy Chiang' => 'jeremy@steamclock.com' }
  spec.summary = 'Bluejay is a simple Swift framework for building reliable Bluetooth apps.'
  spec.homepage = 'https://github.com/steamclock/bluejay'
  spec.source = { git: 'https://github.com/steamclock/bluejay.git', tag: 'v0.8.9' }
  spec.source_files = 'Bluejay/Bluejay/*.{h,swift}'
  spec.framework = 'SystemConfiguration'
  spec.platform = :ios, '11.0'
  spec.requires_arc = true
  spec.swift_version = '5.0'

  #s.source_files = 'iOSDFULibrary/Classes/**/*'
  #s.dependency 'ZIPFoundation', '= 0.9.11'

  spec.source_files = 'Bluejay/Bluejay/*'
  spec.dependency 'iOSDFULibrary', '= 4.11.1'
  spec.dependency 'ZIPFoundation', '= 0.9.11'
end
