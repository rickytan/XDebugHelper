#
# Be sure to run `pod lib lint XDebugHelper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XDebugHelper'
  s.version          = '0.1.0'
  s.summary          = 'A short description of XDebugHelper.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rickytan/XDebugHelper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rickytan' => 'ricky.tan.xin@gmail.com' }
  s.source           = { :git => 'https://github.com/rickytan/XDebugHelper.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'XDebugHelper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'XDebugHelper' => ['XDebugHelper/Assets/*.png']
  # }
end
