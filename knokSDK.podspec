#
# Be sure to run `pod lib lint knokSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name             = 'knokSDK'
  s.version          = '0.0.5'
  s.summary          = 'knok library'
  s.description      = <<-DESC
  Private library to access knok services.
                       DESC
  s.homepage         = 'https://knokcare.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'andresousa' => 'andre@iterar.co' }
  s.source           = { :git => 'https://github.com/knok-healthcare/ios-knok-sdk.git', :tag => s.version.to_s }
  s.platform = :ios, "10.0"
  s.swift_version = "4.0"
  s.ios.deployment_target = '10.0'
  s.source_files = 'knokSDK/**/*'
  s.static_framework = true
  s.dependency 'OpenTok', '2.16.3'
end
