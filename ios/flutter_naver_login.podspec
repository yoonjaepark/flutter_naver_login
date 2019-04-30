#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_naver_login'
  s.version          = '0.1.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # https://github.com/flutter/flutter/issues/14161
  s.dependency  'Alamofire', '~> 5.0.0-beta.5'
  s.dependency 'naveridlogin-sdk-ios', '4.0.12'
  s.static_framework = true
  s.ios.deployment_target = '10.0'
end

