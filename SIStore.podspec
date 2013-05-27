Pod::Spec.new do |s|
  s.name         = "SIStore"
  s.version      = "0.0.3"
  s.summary      = "Sumi Interactive make a new CoreData and iCloud a Third-party library on MagicalRecord."
  s.homepage     = "http://sumi-sumi.com"
  s.license      = 'MIT'
  s.author       = { "Sumi Interactive" => "developer@sumi-sumi.com" }
  s.source       = { :git => "https://github.com/iiiyu/SIStore.git"}
  s.source_files = 'SIStore/*.{h,m}'
  s.resources    = 'SIStore/SIStore.bundle'
  s.framework    = 'CoreData'
  s.dependency 'MagicalRecord', :git => 'git://github.com/iiiyu/MagicalRecord.git', :commit => '7968aa04523eaafc33fea64d15e221146d9a7073'
  s.dependency 'SVProgressHUD'
  s.dependency 'SIAlertView'
  s.requires_arc = true
  s.platform     = :ios
end
