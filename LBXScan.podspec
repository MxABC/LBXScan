Pod::Spec.new do |s|
    s.name         = 'LBXScan'
    s.version      = '1.0.11'
    s.summary      = 'ios scan wrapper'
    s.homepage     = 'https://github.com/MxABC'
    s.license      = 'MIT'
    s.authors      = {'lbxia' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '6.0'
    s.source       = {:git => 'https://github.com/MxABC/LBXScan.git', :tag => s.version}
    s.requires_arc = true
    s.prefix_header_contents = '#import <Foundation/Foundation.h>'
    s.subspec 'LBXScanCore' do |ss|
      ss.source_files = 'LBXScan/LBXScanCore/*.{h,m}'
      ss.subspec 'LibZXing' do |sss|
         sss.source_files = 'LBXScan/LBXScanCore/LibZXing/**/*.{h,m}'
      end
    end
    s.subspec 'LBXScan+UIKit' do |ss|
      ss.source_files = 'LBXScan/LBXScan+UIKit/*.{h,m}'
    end
end
