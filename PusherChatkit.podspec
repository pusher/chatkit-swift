Pod::Spec.new do |s|
  s.name             = 'PusherChatkit'
  s.version          = '1.8.2'
  s.summary          = 'Pusher Chatkit SDK in Swift'
  s.homepage         = 'https://github.com/pusher/chatkit-swift'
  s.license          = 'MIT'
  s.author           = { "Hamilton Chapman" => "hamchapman@gmail.com" }
  s.source           = { git: "https://github.com/pusher/chatkit-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/pusher'

  s.requires_arc = true
  s.source_files = 'Sources/*.swift'

  s.dependency 'PusherPlatform', '~> 0.7.2'
  s.ios.dependency 'PushNotifications', '~> 3.0.1'
  s.macos.dependency 'PushNotifications', '~> 3.0.1'

  s.ios.deployment_target = '10.0'
  s.macos.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
end
