Pod::Spec.new do |s|
    s.name         = 'LBXScan'
    s.version      = '1.1.1'
    s.summary      = 'ios scan wrapper'
    s.homepage     = 'https://github.com/MxABC'
    s.license      = 'MIT'
    s.authors      = {'lbxia' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '6.0'
    s.source       = {:git => 'https://github.com/MxABC/LBXScan.git', :tag => s.version}
    s.requires_arc = true
    s.source_files = 'LBXScan/*.{h,m}'
    s.prefix_header_contents = '#import <Foundation/Foundation.h>'
    s.dependency 'ZXingObjC', '~> 3.0'
end
