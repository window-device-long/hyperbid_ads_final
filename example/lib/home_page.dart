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
      body: Column(
        children: [
          SizedBox(height: 300),

          HyperbidNativeAd(
            group: "group1",
            viewId: "native-1",
            placementId: "k5268a2bc6f7f3cc",
            typeAd: HBTypeAd.nativeMedium,
          ),
        ],
      ),
    );
  }
}
