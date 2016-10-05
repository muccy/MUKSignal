Pod::Spec.new do |s|
  s.name             = "MUKSignal"
  s.version          = "1.0.4"
  s.summary          = "Dispatch signals which could be subscribed by various subscribers."
  s.description      = <<-DESC
                        Dispatch signals which could be subscribed by various subscribers. Subscription could also be suspended. This library also contains specific signals, like notification signals, KVO signals and control target-action signals.
                       DESC
  s.homepage         = "https://github.com/muccy/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/#{s.name}.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  
  s.source_files = 'Pod/**/*.{h,m}'
end
