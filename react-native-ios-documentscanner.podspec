require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
name= 'react-native-ios-documentscanner'

Pod::Spec.new do |s|

  s.name           = package['name']
  s.version        = package['version']
  s.summary        = package['description']
  s.homepage       = package['repository']['url']
  s.license        = package['license']
  s.author         = package['author']
  s.source         = { :git => s.homepage, :tag => 'v#{s.version}' }

  s.requires_arc   = true
  s.ios.deployment_target = '10.0'

  s.preserve_paths = 'package.json', 'index.ts'
  s.source_files   = 'ios/*.{h,m,swift}'
  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '"$(SDKROOT)/usr/lib/swift"' }

  s.dependency 'React'

end