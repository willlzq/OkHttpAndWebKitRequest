#
# Be sure to run `pod lib lint OkHttpAndWebKitRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OkHttpAndWebKitRequest'
  s.version          = '1.6'
  s.summary          = '通过HTTP或WEBKIT来完整获取网页的HTML'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                         DESC
  

  s.homepage         = 'https://github.com/willlzq/OkHttpAndWebKitRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'willlzq' => 'willlzq@hotmail.com' }
  s.source           = { :git => 'https://github.com/willlzq/OkHttpAndWebKitRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'OkHttpAndWebKitRequest/Classes/**/*'
  
   s.resource_bundles = {
     'OkHttpAndWebKitRequest' => ['OkHttpAndWebKitRequest/Assets/*.js','OkHttpAndWebKitRequest/Assets/*.json']
   }

   s.frameworks = 'UIKit'
   s.dependency 'GZIP'
   s.dependency 'AFNetworking'
   s.dependency 'UniversalDetector'
end
