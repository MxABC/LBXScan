Pod::Spec.new do |s|
  s.name         = "LBXScan"
  s.version      = "1.0.2"
  s.summary      = "ios scan wrapper."
  s.homepage     = "https://github.com/MxABC/LBXScan"

  s.license      = "MIT"
  s.author       = { "lbxia" => "lbxia20091227@foxmail.com" }

  s.source       = { :git => "https://github.com/MxABC/LBXScan.git",:tag => s.version }

  s.ios.deployment_target = '6.0'

  s.source_files = 'LBXScan/*.{m,h}'
  s.public_header_files = 'LBXScan/**/*.h'

  s.requires_arc = true



  s.subspec 'LBXScan' do |ss|
  ss.source_files = 'LBXScan/**/*.{h,m}'
  end

  s.subspec 'LBXScan+UIKit' do |ss|
  ss.source_files = 'LBXScan+UIKit/**/*.{h,m}'
  s.resouce = 'LBXScan+UIkit/CodeScan.bundle'
  end


end
