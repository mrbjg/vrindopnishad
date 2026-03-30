Pod::Spec.new do |s|
  s.name             = 'SwiftTryCatch'
  s.version          = '0.0.1'
  s.summary          = 'Adds try/catch for Swift.'
  s.description      = 'Ads try/catch support for Swift to catch Objective-C NSExceptions.'
  s.homepage         = 'https://github.com/williamFalcon/SwiftTryCatch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'William Falcon' => 'william@hacstudios.com' }
  s.source           = { :git => 'https://github.com/williamFalcon/SwiftTryCatch.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.source_files = 'SwiftTryCatch.{h,m}'
  s.public_header_files = 'SwiftTryCatch.h'
  s.requires_arc = true
end
