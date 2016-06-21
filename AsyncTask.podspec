#
# Be sure to run `pod lib lint AsyncTask.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AsyncTask'
  s.version          = '0.1.3'
  s.summary          = 'An asynchronous programming library for Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An asynchronous programming library for Swift that is composable and protocol oriented.
                       DESC

  s.homepage         = 'https://github.com/zhxnlai/AsyncTask'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zhixuan Lai' => 'zhxnlai@gmail.com' }
  s.source           = { :git => 'https://github.com/zhxnlai/AsyncTask.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.requires_arc = true

  s.source_files = 'Source/Base/*.swift'

  # s.resource_bundles = {
  #   'AsyncTask' => ['AsyncTask/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
