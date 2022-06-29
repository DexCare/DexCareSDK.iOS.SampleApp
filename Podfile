# A private repo with the podspec. Please make sure you have github access before installing
source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'
inhibit_all_warnings!

def auth0_pods
  pod 'Auth0'
  pod 'Lock', "~> 2.24"
end

def dexcare_pod
 pod 'DexcareSDK', :git => 'https://github.com/Dexcare/DexcareSDK-iOS.git', :tag => '8.0.1'
end

target 'DexCareSDK.iOS.SampleApp' do
  use_frameworks!

  # Pods for DexCareSDK.iOS.SampleApp
  dexcare_pod
  auth0_pods

  pod 'PromiseKit'
  pod 'KeychainAccess'

  #Keyboard Avoidance on forms
  pod 'TPKeyboardAvoiding'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Needed for Xcode12 xcframework
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
    end
  end
end
