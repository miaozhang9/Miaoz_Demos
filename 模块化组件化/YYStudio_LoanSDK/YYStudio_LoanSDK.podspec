#
#  Be sure to run `pod spec lint YYStudio_LoanSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#




Pod::Spec.new do |s|

  s.name         = "YYStudio_LoanSDK"
  s.version      = "0.0.6"
  s.summary      = "YYStudio_LoanSDK Info"
  s.license      = { :type => "COMMERCIAL", :file => "LICENSE" }
  s.homepage     = "http://10.11.180.29/mobileDevelopers/YYStudio_LoanSDK"
  s.author       = { "zhangmiao" => "395052985@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "http://10.11.180.29/mobileDevelopers/YYStudio_LoanSDK.git", :tag => s.version }
  s.source_files = "YYStudio_LoanSDK/QHLoanlib/**/*.{h,m,c,mm}"
  s.public_header_files = 'YYStudio_LoanSDK/QHLoanlib/**/*.h'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  s.resources = 'YYStudio_LoanSDK/QHLoanlib/**/*.{bundle}'
  s.frameworks = "Foundation", "UIKit", "Webkit"
  #s.dependency 'Loan_iOS_Custom_Framework', '~> 0.0.1'
  #s.vendored_frameworks = 'YYStudio_LoanSDK/FaceRecognitionLib/OCFTFaceDetect.framework'
  #s.libraries    =  "z", "c++", 'stdc++'

end

