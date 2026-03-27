#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hyperbid_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hyperbid_ads'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
s.dependency 'HyperbidToolsMCSDK', '3.6.16'
s.dependency 'MCSDKMaterialPlugin', '1.1.0'
s.dependency 'HyperbidToolsMCToponAdapter', '6.5.34.0'
s.dependency 'HyperbidToolsMCMaxAdapter', '13.5.0.1'
s.dependency 'HyperbidToolsMCAdmobAdapter', '12.12.0.0'


s.dependency 'TPNMediationVungleAdapter', '7.6.0.1'
s.dependency 'TPNMediationUnityAdsAdapter', '4.16.2.0'
s.dependency 'TPNMediationIronSourceAdapter', '9.2.0.0.0'
s.dependency 'TPNMediationBigoAdapter', '5.0.0.0'
s.dependency 'TPNMediationPangleAdapter', '7.8.0.6.0'
s.dependency 'TPNMediationFacebookAdapter', '6.21.0.0'
s.dependency 'TPNMediationAdmobAdapter', '12.12.0.0'
s.dependency 'TPNMediationInmobiAdapter', '10.8.8.0'
s.dependency 'TPNMediationApplovinAdapter', '13.5.0.1'
s.dependency 'TPNMediationMintegralAdapter', '7.7.9.0'
s.dependency 'TPNMediationChartboostAdapter', '9.10.1.0'
s.dependency 'TPNMediationYandexAdapter', '7.16.1.0'


s.dependency 'AppLovinMediationVungleAdapter', '7.6.0.0'
s.dependency 'AppLovinMediationMobileFuseAdapter', '1.9.3.0'
s.dependency 'AppLovinMediationUnityAdsAdapter', '4.16.2.0'
s.dependency 'AppLovinMediationIronSourceAdapter', '9.2.0.0.0'
s.dependency 'AppLovinMediationBigoAdsAdapter', '5.0.0.0'
s.dependency 'AppLovinMediationFacebookAdapter', '6.21.0.0'
s.dependency 'AppLovinMediationGoogleAdapter', '12.12.0.0'
s.dependency 'AppLovinMediationGoogleAdManagerAdapter', '12.12.0.0'
s.dependency 'AppLovinMediationInMobiAdapter', '10.8.8.0'
s.dependency 'AppLovinMediationMintegralAdapter', '7.7.9.0.0'
s.dependency 'AppLovinMediationChartboostAdapter', '9.10.1.0'
s.dependency 'AppLovinMediationYandexAdapter', '7.16.1.0'
s.dependency 'AppLovinMediationFyberAdapter', '8.4.1.0'


s.dependency 'GoogleMobileAdsMediationVungle', '7.6.0.0'
s.dependency 'GoogleMobileAdsMediationUnity', '4.16.2.0'
s.dependency 'GoogleMobileAdsMediationIronSource', '9.2.0.0.0'
s.dependency 'GoogleMobileAdsMediationPangle', '7.8.0.6.0'
s.dependency 'GoogleMobileAdsMediationFacebook', '6.21.0.0'
s.dependency 'GoogleMobileAdsMediationInMobi', '10.8.8.0'
s.dependency 'GoogleMobileAdsMediationAppLovin', '13.5.0.0'
s.dependency 'GoogleMobileAdsMediationMintegral', '7.7.9.0'
s.dependency 'GoogleMobileAdsMediationChartboost', '9.10.1.0'

  s.frameworks = [
    'AdSupport',
    'StoreKit',
    'AppTrackingTransparency'
  ]
s.resources = ['ios/Classes/core/Views/*.xib']
  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'hyperbid_ads_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
