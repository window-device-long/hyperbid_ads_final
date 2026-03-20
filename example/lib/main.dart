import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hyperbid_ads/hyperbid_ads.dart';
import 'package:hyperbid_ads/views/HyperBidBanner.dart';
import 'package:hyperbid_ads/views/HyperBidNative.dart';
import 'package:hyperbid_ads/views/hyperbid_nativefull_inter.dart';
import 'package:hyperbid_ads_example/firebase_options.dart';
import 'package:hyperbid_ads_example/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sdk = HyperbidAds.I;

  await sdk.initSdk(
    appId: "j69de0de8bab7556",
    appKey: "j17a48b9fc6faa4120a5e1be789b2fc889a43a1c0",
    appName: "AI-Video",
    firebase: DefaultFirebaseOptions.currentPlatform,
    sandbox: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    HyperbidAds.initInterstitial("k50c2b287c259041");
    HyperbidAds.initReward(placementId: "kedfa19757f78aa5");
    HyperbidAds.initAppOpen(placementId: "");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {} on PlatformException {
      print('Failed to get platform version.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(showPerformanceOverlay: true, home: MainPage());
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HomePage(),
              // HyperbidNativeAd(
              //   group: "group1",
              //   viewId: "native-",
              //   placementId: "k5268a2bc6f7f3cc",
              //   typeAd: HBTypeAd.nativeMedium,
              // ),

              // HyperbidFullscreenAdsFlow(
              //   group: "home",
              //   interPlacementId: "k50c2b287c259041",
              //   nativePlacementId: "k5268a2bc6f7f3cc",
              //
              //   onFinished: () => Navigator.pop(context),
              //   screen: "Home",
              // ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              HyperbidAds.showInterstitial(screen: "home_view");
            },
            child: Text("Interstitial"),
          ),
          TextButton(
            onPressed: () {
              HyperbidAds.showReward(
                screen: "home_view",
                timeout: Duration(seconds: 10),
              );
            },
            child: Text("Reward"),
          ),
          SizedBox(
            height: 90,
            child: HyperBidBanner(
              name: "home_banner",
              placementId: "k05814978bc80c41",
              type: "banner",
            ),
          ),
        ],
      ),
    );
  }
}
