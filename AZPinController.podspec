#
# Be sure to run `pod lib lint AZPinController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AZPinController'
  s.version          = '0.1.12'
  s.summary          = 'Simple UIViewController for pin code entering'
  s.description      = 'AZPinController can be used for cases when you need to enter a pin code of various lengths'

  s.homepage         = 'https://github.com/kalmurzayev/AZPinController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kalmurzayev' => 'kalmurzayev@gmail.com' }
  s.source           = { :git => 'https://github.com/kalmurzayev/AZPinController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'AZPinController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AZPinController' => ['AZPinController/Assets/*.png']
  # }

  s.frameworks = 'UIKit'
  s.dependency 'SnapKit'
end
