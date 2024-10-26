Pod::Spec.new do |s|
  s.name = 'EasyCode'
  s.license = 'MIT'
  s.version = '1.3.1'
  s.summary = 'EasyCode'
  s.homepage = 'https://github.com/Salmik/EaseCode'
  s.authors = { 'Salmik' => 'salmik94@gmail.com' }
  s.source = { :git => 'https://github.com/Salmik/EaseCode.git', :tag => s.version }
  s.ios.deployment_target  = '14.0'
  s.swift_versions = ['5.0']
  s.source_files = 'EasyCode/Source/**/*.swift'
end

