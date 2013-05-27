Pod::Spec.new do |s|
  s.name         = "SIStore"
  s.version      = "0.0.3"
  s.summary      = "Sumi Interactive make a new CoreData and iCloud a Third-party library on MagicalRecord."
  s.homepage     = "http://iiiyu.com"
  s.license      = 'MIT'
  s.author       = { "Xiao ChenYu" => "apple.iiiyu@gmail.com" }
  s.source       = { :git => "https://iiiyu@bitbucket.org/iiiyu/sistore.git"}
  s.source_files = 'SIStore/*.{h,m}'
  s.preserve_paths  = 'SIStoreDemo'
  s.resources    = 'SIStore/SIStore.bundle'
  s.framework    = 'CoreData'
  s.dependency 'MagicalRecord'
  s.dependency 'SVProgressHUD'
  s.requires_arc = true
  s.platform     = :ios
end
