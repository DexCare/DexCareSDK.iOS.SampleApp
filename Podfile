# A private repo with the podspec. Please make sure you have github access before installing
source 'https://cdn.cocoapods.org/'

platform :ios, '13.0'
inhibit_all_warnings!

def auth0_pods
  pod 'Auth0', '~> 1.0'
  pod 'Lock', '~> 2.0'
end

def dexcare_pod
 pod 'DexcareSDK', :git => 'https://github.com/Dexcare/DexcareSDK-iOS.git', :tag => '6.1.6'
end

target 'DexCareSDK.iOS.SampleApp' do
  use_frameworks!

  # Pods for DexCareSDK.iOS.SampleApp
  dexcare_pod
  auth0_pods

  pod 'KeychainAccess'

  #Keyboard Avoidance on forms
  pod 'TPKeyboardAvoiding'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Needed for Xcode12 xcframework
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
