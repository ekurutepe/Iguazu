#
#  Be sure to run `pod spec lint Iguazu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Iguazu"
  s.version      = "1.2.1"
  s.summary      = "An aviation file format parser written in Swift"
  s.description  = <<-DESC
Iguazu is a new project and still work in progress. The goal is to have a Swift framework with support for various popular aviation file formats to facilitate development of apps for pilots on the iOS platform.

Currently includes basic support for the following formats:

OpenAir Airspace description
IGC Glider log format (deserialization only)
For more details on the Iguazu Falls: https://en.wikipedia.org/wiki/Iguazu_Falls
                   DESC
  s.homepage     = "https://github.com/ekurutepe/Iguazu"
  s.license      = "MIT"
  s.author    = "Engin Kurutepe"
  s.social_media_url   = "http://twitter.com/ekurutepe"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/ekurutepe/Iguazu.git", :tag => "#{s.version}" }
  s.source_files  = "Iguazu", "Iguazu/**/*.{swift}"
  s.swift_version = "4.1"
end
