import 'package:flutter/material.dart';
import 'package:hyperbid_ads/core/modals/hb_type_ad.dart';
import 'package:hyperbid_ads/views/HyperBidNative.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return HyperbidNativeAd(
            group: "home_native_$index",
            placementId: "kfc98a6c32d23a57",
            typeAd: HBTypeAd.nativeSmall,
          );
        },
      ),
    );
  }
}
