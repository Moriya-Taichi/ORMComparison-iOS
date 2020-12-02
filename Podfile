platform :ios, '14.0'

target 'DatabaseComparison' do
  use_frameworks!
	
  pod 'RealmSwift', '5.4.4'
  pod 'GRDB.swift', '4.14.0'
  pod 'FMDB', '2.7.5'
end

post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
             config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
             config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'
    
         end
     end
 end