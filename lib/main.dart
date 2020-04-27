import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watsonapp/views/splash.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  FlareCache.doesPrune = false;
  warmupFlare().then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: CustomColors.blackWatson,
      ),
      home: MySplashScreen(),
    );
  }
}

var _assetsToWarmup = [
  AssetFlare(bundle: rootBundle, name: "assets/flare/watsonLogo.flr"),
  AssetFlare(bundle: rootBundle, name: "assets/flare/watsonAvatar.flr"),
  AssetFlare(bundle: rootBundle, name: "assets/flare/loadingDots.flr")
];

Future<void> warmupFlare() async {
  for (final flare in _assetsToWarmup) {
    await cachedActor(flare);
  }
}

class CustomColors {
  CustomColors._(); // this basically makes it so you can instantiate this class

  static const _blackWatson = 0xFF1E1E1E;

  static const MaterialColor blackWatson = const MaterialColor(
    _blackWatson,
    const <int, Color>{
      50: const Color(0x661E1E1E),
      100: const Color(0x771E1E1E),
      200: const Color(0x881E1E1E),
      300: const Color(0x991E1E1E),
      400: const Color(0xAA1E1E1E),
      500: const Color(0xBB1E1E1E),
      600: const Color(0xCC1E1E1E),
      700: const Color(0xDD1E1E1E),
      800: const Color(0xEE1E1E1E),
      900: const Color(0xFF1E1E1E),
    },
  );
}
