#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ym_fluttertoast'
  s.version          = '1.0.1'
  s.summary          = 'Toast Library for Flutter'
  s.description      = <<-DESC
Toast Library for FLutter
                       DESC
  s.homepage         = 'https://github.com/yashmanghnani/ym_fluttertoast'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Karthik Ponnam' => 'ponnamkarthik3@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.resource_bundles = {'fluttertoast_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
