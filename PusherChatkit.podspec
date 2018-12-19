Pod::Spec.new do |s|
  s.name             = 'PusherChatkit'
  s.version          = '1.2.1'
  s.summary          = 'Pusher Chatkit SDK in Swift'
  s.homepage         = 'https://github.com/pusher/chatkit-swift'
  s.license          = 'MIT'
  s.author           = { "Hamilton Chapman" => "hamchapman@gmail.com" }
  s.source           = { git: "https://github.com/pusher/chatkit-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/pusher'

  s.requires_arc = true
  s.source_files = 'Sources/*.swift'

  s.dependency 'PusherPlatform', '~> 0.6'
  s.ios.dependency 'BeamsChatkit', '~> 1.2'
  s.macos.dependency 'BeamsChatkit', '~> 1.2'

  s.ios.deployment_target = '10.0'
  s.macos.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end
