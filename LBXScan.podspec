Pod::Spec.new do |s|
    s.name         = 'LBXScan'
    s.version      = '1.0.6'
    s.summary      = 'ios scan wrapper'
    s.homepage     = 'https://github.com/MxABC/LBXScan'
    s.license      = 'MIT'
    s.authors      = {'lbxia' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '6.0'
    s.source       = {:git => 'https://github.com/MxABC/LBXScan.git', :tag => s.version}
    s.source_files = 'LBXScan/*.{h,m}'
    s.resource     = 'LBXScan/LBXScan+UIKit/CodeScan.bundle'
    s.requires_arc = true
    s.subspec 'LBXScanCore' do |ss|
      ss.source_files = 'LBXScan/LBXScanCore/*.{h,m}'
      ss.subspec 'LibZXing' do |sss|
         sss.subspec 'ZXingWrapper' do |ssss|
         ssss.source_files = 'LBXScan/LBXScanCore/LibZXing/ZXingWrapper/*.{h,m}'
         end
         sss.subspec 'ZXingObjC' do |ssss|
         ssss.source_files = 'LBXScan/LBXScanCore/LibZXing/ZXingObjC/**/*.{h,m}'
         end
      end
    end
    s.subspec 'LBXScan+UIKit' do |ss|
      ss.source_files = 'LBXScan/LBXScan+UIKit/*.{h,m}'
    end
end
