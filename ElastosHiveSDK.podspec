#
#  Be sure to run `pod spec lint hive.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ElastosHiveSDK"
  s.version      = "1.0.1"
  s.summary      = "Elastos Hive iOS SDK Distribution."
  s.swift_version = '4.2'
  s.description  = 'Elastos hive ios sdk framework distribution.'
  s.homepage     = "https://www.elastos.org"
  s.license      = { :type => "MIT", :file => "ElastosHiveSDK-framework/LICENSE" }
  s.author       = { "hive-dev" => "release@elastos.org" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = {'http':'https://github.com/elastos/Elastos.NET.Hive.Swift.SDK/releases/download/release-v1.0.1/ElastosHiveSDK-framework.zip'}
  s.vendored_frameworks = 'ElastosHiveSDK-framework/*.framework'
  s.source_files = 'ElastosHiveSDK-framework/ElastosHiveSDK.framework/**/*.h'


end
