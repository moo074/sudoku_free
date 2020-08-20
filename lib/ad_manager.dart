import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

class AdManager {
  static BannerAd _bannerAd;

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3659138431539550~1543870245";
      // } else if (Platform.isIOS) {
      //   return "<YOUR_IOS_ADMOB_APP_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      //return "ca-app-pub-3659138431539550/2759188490"; // live
      return "ca-app-pub-3940256099942544/1033173712"; //test ad
      // } else if (Platform.isIOS) {
      //   return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      //return "ca-app-pub-3659138431539550/3928799938"; // live
      return "ca-app-pub-3940256099942544/6300978111"; //test ad
      // } else if (Platform.isIOS) {
      //   return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );
  }

  static void showBannerAd() {
    if (_bannerAd == null) _bannerAd = _createBannerAd();
    _bannerAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  static void hideBannerAd() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    print('hideBannerAd');
  }
}
