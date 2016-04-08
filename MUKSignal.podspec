Pod::Spec.new do |s|
  s.name             = "MUKSignal"
  s.version          = "1.0.0"
  s.summary          = "Send and receive signals."
  s.description      = <<-DESC
                        Dispatch signals and subscribe via a block-based API.
                       DESC
  s.homepage         = "https://github.com/muccy/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/#{s.name}.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  
  s.subspec "Core" do |ss|
  s.source_files = 'Pod/**/*.{h,m}'
end
