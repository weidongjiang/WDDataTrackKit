#
#  Be sure to run `pod spec lint HTIOSDataTrack.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = "HTIOSDataTrack"
  s.version          = "2.0.4"
  s.summary          = "-"
  s.homepage         = "https://git.corp.hetao101.com/teaching/commonsdk/htiosdatatrackkit"
  s.platform         = :ios, "10.0"

  s.authors          = "jiangweidong"
  s.source           = { :git => "https://git.corp.hetao101.com/teaching/commonsdk/htiosdatatrackkit.git", :tag => s.version }
  s.requires_arc     = true
  s.source_files     =  "framework/DataTrack/HTDataTrack.h", "framework/DataTrack/**/*.{h,m}", "framework/DataTrack/**/**/*.{h,m}"

  non_arc_files   = "framework/DataTrack/common/HTDataTrackReachability.{h,m}"
  s.exclude_files = non_arc_files
  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
  end

  s.dependency 'FMDB', '2.6.2'
  s.dependency 'AFNetworking', '3.1.0'
  s.dependency 'SensorsAnalyticsSDK'
end