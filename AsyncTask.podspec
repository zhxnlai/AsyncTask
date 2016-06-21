Pod::Spec.new do |s|
  s.name             = 'AsyncTask'
  s.version          = '0.1.3'
  s.summary          = 'An asynchronous programming library for Swift.'
  s.description      = <<-DESC
An asynchronous programming library for Swift that is composable and protocol oriented.
                       DESC
  s.homepage         = 'https://github.com/zhxnlai/AsyncTask'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zhixuan Lai' => 'zhxnlai@gmail.com' }
  s.source           = { :git => 'https://github.com/zhxnlai/AsyncTask.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/Base/*.swift'
  s.requires_arc = true
end
