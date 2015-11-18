Pod::Spec.new do |s|
  s.name         = "LBXScan"
  s.version      = "1.0.1"
  s.summary      = "ios wrapper code."
  s.homepage     = ""

  s.license      = "MIT"
  s.author       = { "lbxia" => "lbxia20091227@foxmail.com" }

  s.source       = { :git => "https://git.oschina.net/lbxia/CSCCommon.git",:tag => s.version }

  s.ios.deployment_target = '7.0'

  s.source_files = 'LBXScan/*.{m,h}'
  s.public_header_files = 'LBXScan/**/*.h'

  s.requires_arc = true

  s.subspec 'LBXScan' do |ss|
  ss.source_files = 'LBXScan/LBXScan/*.{h,m}'
  end

  s.subspec 'LBXScan+UIKit' do |ss|
  ss.source_files = 'LBXScan/LBXScan+UIKit/*.{h,m}'
  end


end
