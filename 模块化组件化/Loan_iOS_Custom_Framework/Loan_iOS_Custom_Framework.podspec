#
#  Be sure to run `pod spec lint QHLoanSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "Loan_iOS_Custom_Framework"
  s.version      = "0.0.2"
  s.summary      = "A short description of Loan_iOS_Custom_Framework"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                    this is Loan_iOS_Custom_Framework
                   DESC

  s.homepage     = "http://10.11.180.29/mobileDevelopers/Loan_iOS_Custom_Framework"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  #s.license      = "MIT (example)"
  s.license      = { :type => "COMMERCIAL", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "zhangmiao" => "395052985@qq.com" }
  # Or just: s.author    = "zhangmiao"
  # s.authors            = { "zhangmiao" => "395052985@qq.com" }
  # s.social_media_url   = "http://twitter.com/zhangmiao"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "http://10.11.180.29/mobileDevelopers/Loan_iOS_Custom_Framework.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
  #注释-----
  #s.source_files  = "Classes", "Classes/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

# Custom third-party libraries

  s.subspec 'Loan_OCFTFaceDetect' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
    ss.source_files = 'Loan_iOS_Custom_Framework/Loan_OCFTFaceDetect/Loan_OCFTFaceDetect/OCFTFaceDetect.framework/Headers/**.h'
    ss.public_header_files = 'Loan_iOS_Custom_Framework/Loan_OCFTFaceDetect/Loan_OCFTFaceDetect/OCFTFaceDetect.framework/Headers/**.h'
    ss.vendored_frameworks = 'Loan_iOS_Custom_Framework/Loan_OCFTFaceDetect/Loan_OCFTFaceDetect/OCFTFaceDetect.framework'
   # ss.frameworks = "Foundation", "UIKit", "Webkit", "AVFoundation", "CoreGraphics", "QuartzCore", "CoreVideo"
   
  end


 #s.subspec 'FaceRecognitionLib' do |ss|
  #  ss.ios.deployment_target = '8.0'
   # ss.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

    #ss.source_files = "FaceRecognitionLib/FaceRecognitionLib/**/*.{h,m,c}"
   # ss.public_header_files = "FaceRecognitionLib/FaceRecognitionLib/**/*.h"
    #ss.resources = 'FaceRecognitionLib/FaceRecognitionLib/OCFTSDK/**/*.{bundle}'
    #ss.frameworks = "Foundation", "UIKit", "AVFoundation", "CoreGraphics", "QuartzCore", "CoreVideo"
    #ss.vendored_frameworks = 'FaceRecognitionLib/FaceRecognitionLib/OCFTSDK/OCFTFaceDetect.framework'
   # ss.dependency 'QHLoanSDK/QHOCFTFaceDetect'
  #end


 #s.subspec 'QHOCFTFaceDetect' do |ss|
  #ss.ios.deployment_target = '8.0'
  #ss.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  #ss.source_files = "QHOCFTFaceDetect/QHOCFTFaceDetect/**/*.{h,c,m}"
  #ss.public_header_files = "QHOCFTFaceDetect/QHOCFTFaceDetect/**/*.h"

  #ss.vendored_frameworks = 'QHOCFTFaceDetect/QHOCFTFaceDetect/OCFTFaceDetect.framework'

#end
  



  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"




end
