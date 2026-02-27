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
s.dependency 'HyperbidToolsMCSDK', '3.6.10'
s.dependency 'HyperbidToolsMCToponAdapter', '6.4.87.1'
s.dependency 'HyperbidToolsMCMaxAdapter', '13.2.0.5'
s.dependency 'HyperbidToolsMCAdmobAdapter', '12.3.0.2'


s.dependency 'TPNVungleSDKAdapter', '6.4.87.1'
s.dependency 'TPNUnityAdsSDKAdapter', '6.4.87'
s.dependency 'TPNIronSourceSDKAdapter', '6.4.87'
s.dependency 'TPNBigoSDKAdapter', '6.4.87'
s.dependency 'TPNPangleSDKAdapter', '6.4.87'
s.dependency 'TPNFacebookSDKAdapter', '6.4.87'
s.dependency 'TPNAdmobSDKAdapter', '6.4.87'
s.dependency 'TPNInmobiSDKAdapter', '6.4.87'
s.dependency 'TPNApplovinSDKAdapter', '6.4.87'
s.dependency 'TPNMintegralSDKAdapter', '6.4.87'
s.dependency 'TPNChartboostSDKAdapter', '6.4.87'
s.dependency 'TPNYandexSDKAdapter', '6.4.87'


s.dependency 'AppLovinMediationVungleAdapter', '7.5.1.4'
s.dependency 'AppLovinMediationUnityAdsAdapter', '4.14.2.0'
s.dependency 'AppLovinMediationIronSourceAdapter', '8.8.0.0.0'
s.dependency 'AppLovinMediationBigoAdsAdapter', '4.7.0.0'
s.dependency 'AppLovinMediationFacebookAdapter', '6.17.1.0'
s.dependency 'AppLovinMediationGoogleAdapter', '12.3.0.0'
s.dependency 'AppLovinMediationInMobiAdapter', '10.8.2.0'
s.dependency 'AppLovinMediationMintegralAdapter', '7.7.7.0.0'
s.dependency 'AppLovinMediationChartboostAdapter', '9.8.1.0'
s.dependency 'AppLovinMediationYandexAdapter', '7.12.1.0'


s.dependency 'GoogleMobileAdsMediationVungle', '7.5.1.0'
s.dependency 'GoogleMobileAdsMediationUnity', '4.14.2.0'
s.dependency 'GoogleMobileAdsMediationIronSource', '8.8.0.0.0'
s.dependency 'GoogleMobileAdsMediationFacebook', '6.17.1.0'
s.dependency 'GoogleMobileAdsMediationInMobi', '10.8.2.0'
s.dependency 'GoogleMobileAdsMediationAppLovin', '13.2.0.0'
s.dependency 'GoogleMobileAdsMediationMintegral', '7.7.7.0'
s.dependency 'GoogleMobileAdsMediationChartboost', '9.8.1.0'
s.dependency 'GoogleMobileAdsMediationMyTarget', '5.29.1.0'

  s.frameworks = [
    'AdSupport',
    'StoreKit',
    'AppTrackingTransparency'
  ]
  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'hyperbid_ads_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
