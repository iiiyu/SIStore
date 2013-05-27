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
  s.dependency 'MagicalRecord'
  s.dependency 'SVProgressHUD'
  s.dependency 'SIAlertView'
  s.requires_arc = true
  s.platform     = :ios
end
