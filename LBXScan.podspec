Pod::Spec.new do |s|
    s.name         = 'LBXScan'
    s.version      = '2.1'
    s.summary      = 'ios scan wrapper'
    s.homepage     = 'https://github.com/MxABC/LBXScan'
    s.license      = 'MIT'
    s.authors      = {'lbxia' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/MxABC/LBXScan.git', :tag => s.version}
    s.requires_arc = true
    s.prefix_header_contents = '#import <Foundation/Foundation.h>'


    s.default_subspec = 'All'

    s.subspec 'Types' do |type|
    type.source_files = 'LBXScan/*.{h,m}'
    end

    s.subspec 'All' do |all|
      all.source_files = 'LBXScan/LBXNative/*.{h,m}','LBXScan/LBXZXing/**/*.{h,m}','LBXScan/LBXZBar/*.{h,m}','LBXScan/UI/*.{h,m}'
      all.libraries = 'iconv','z'
      all.resource     = 'LBXScan/UI/CodeScan.bundle'
      all.dependency 'ZBarSDK', '~> 1.3.1'
      all.dependency 'LBXScan/Types','~> 2.0'
      all.ios.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'ImageIO', 'QuartzCore'
      all.prefix_header_contents = '#import "LBXScanNative.h"','#import "ZXingWrapper.h"','#import "LBXZBarWrapper.h"','#import "LBXScanView.h"'
    end

    s.subspec 'LBXNative' do |lbxNative|
      lbxNative.source_files = 'LBXScan/LBXNative/*.{h,m}'
      lbxNative.ios.frameworks = 'AVFoundation'
      lbxNative.prefix_header_contents = '#import "LBXScanNative.h"'
      lbxNative.dependency 'LBXScan/Types','~> 2.0'
    end

    s.subspec 'LBXZXing' do |lbxZXing|
      lbxZXing.source_files = 'LBXScan/LBXZXing/**/*.{h,m}'
      lbxZXing.ios.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'ImageIO', 'QuartzCore'
      lbxZXing.prefix_header_contents = '#import "ZXingWrapper.h"'
      lbxZXing.dependency 'LBXScan/Types','~> 2.0'
    end

    s.subspec 'LBXZBar' do |lbxZBar|
       lbxZBar.source_files = 'LBXScan/LBXZBar/*.{h,m}'
       lbxZBar.libraries = 'iconv','z'
       lbxZBar.dependency 'ZBarSDK', '~> 1.3.1'
       lbxZBar.ios.frameworks = 'AVFoundation', 'CoreGraphics', 'CoreMedia'
       lbxZBar.prefix_header_contents = '#import "LBXZBarWrapper.h"'
       lbxZBar.dependency 'LBXScan/Types','~> 2.0'
    end
  
    s.subspec 'UI' do |ui|
      ui.source_files = 'LBXScan/UI/*.{h,m}'
      ui.resource     = 'LBXScan/UI/CodeScan.bundle'
      ui.prefix_header_contents = '#import "LBXScanView.h"'
      ui.dependency 'LBXScan/Types','~> 2.0'
    end

end
