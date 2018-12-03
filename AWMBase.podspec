#
# Be sure to run `pod lib lint AWMBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AWMBase'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AWMBase.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yinfan/AWMBase'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yinfan' => '327148064@qq.com' }
  s.source           = { :git => 'https://github.com/nianhan2011/AWMBase.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AWMBase/Classes/**/*'
  
  #
  s.dependency 'AFNetworking', '~> 3.1'
  s.dependency 'ReactiveCocoa', '~> 2.5'
  s.dependency 'Objection', '~> 1.6'
  #
  s.dependency 'Masonry', '~> 1.0'
  s.dependency 'MJRefresh', '~> 3.1'
  s.dependency 'MJExtension', '~> 3.0'

#  s.dependency 'Crashlytics'
  s.dependency 'IQKeyboardManager', '~> 6.1'

  s.dependency 'YYCategories', '~> 1.0'
#  s.dependency 'YYText', '~> 1.0'
#  s.dependency 'YYKeyboardManager', '~> 1.0'
  s.dependency 'SDWebImage', '~> 4.0'
  s.dependency 'MJExtension', '~> 3.0'
  s.dependency 'MBProgressHUD', '~> 1.1'
  s.dependency 'WebViewJavascriptBridge', '~> 6.0'

  s.resource_bundles = {
      'AWMBase' => ['AWMBase/Assets/*.xcassets']
  }
  #静态依赖库
#  s.subspec 'TalkingData' do |td|
#      td.library = 'z'
#      td.vendored_library = "Lib/TalkingData-AdTracking/*.a"
#      td.source_files = "Lib/TalkingData-AdTracking/*.h"
#  end
#  s.subspec 'TalkingDataAnalytics' do |td|
#      td.library = 'z'
#      td.vendored_library = "Lib/TalkingData-Analytics/*.a"
#      td.frameworks = 'AdSupport', 'CoreMotion', 'CoreTelephony', 'SystemConfiguration'
#      td.source_files = "Lib/TalkingData-Analytics/*.h"
#  end

end
