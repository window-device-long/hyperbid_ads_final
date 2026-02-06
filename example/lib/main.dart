import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hyperbid_ads/controller/HyperAdsController.dart';
import 'package:hyperbid_ads/views/HyperBidBanner.dart';
import 'package:hyperbid_ads/views/hyperbid_nativefull_inter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await HyperAdsController.initSDK(
        appId: "j87336cfc5a7e4d3",
        appKey: "j2680e56630c3e2fd8857807bc7ac72cefea0879e",
      );
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
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
            MaterialPageRoute(builder: (_) => HyperbidFullscreenAdsFlow(
              group: "home",
              interPlacementId: "k3f32c004b923390",
              nativePlacementId: "kfc98a6c32d23a57",

              onFinished: () => Navigator.pop(context),
              screen: "Home",
            )),
          );
        },
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              HyperAdsController.initInterstitial("k3f32c004b923390");
              HyperAdsController.showInterstitial();
            },
            child: Text("Interstitial"),
          ),
          TextButton(
            onPressed: () {
              HyperAdsController.initReward("kfcbe7867652599a");
              HyperAdsController.showReward();
            },
            child: Text("Reward"),
          ),
          SizedBox(
            height: 90,
            child: HyperBidBanner(
              name: "home_banner",
              placementId: "kd945c8f112cd7b8",
              type: "banner",
            ),
          ),
        ],
      ),
    );
  }
}
