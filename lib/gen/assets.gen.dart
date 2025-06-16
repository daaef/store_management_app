/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart' as _lottie;

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/fainzy_logo.png
  AssetGenImage get fainzyLogo =>
      const AssetGenImage('assets/images/fainzy_logo.png');

  /// File path: assets/images/fainzy_robot.png
  AssetGenImage get fainzyRobot =>
      const AssetGenImage('assets/images/fainzy_robot.png');

  /// File path: assets/images/jp_flag.png
  AssetGenImage get jpFlag => const AssetGenImage('assets/images/jp_flag.png');

  /// File path: assets/images/loading.gif
  AssetGenImage get loading => const AssetGenImage('assets/images/loading.gif');

  /// File path: assets/images/robos.png
  AssetGenImage get robos => const AssetGenImage('assets/images/robos.png');

  /// File path: assets/images/robot1.png
  AssetGenImage get robot1 => const AssetGenImage('assets/images/robot1.png');

  /// File path: assets/images/roby.png
  AssetGenImage get roby => const AssetGenImage('assets/images/roby.png');

  /// File path: assets/images/test_food.png
  AssetGenImage get testFood =>
      const AssetGenImage('assets/images/test_food.png');

  /// File path: assets/images/test_restaurant.jpg
  AssetGenImage get testRestaurant =>
      const AssetGenImage('assets/images/test_restaurant.jpg');

  /// File path: assets/images/us_flag.png
  AssetGenImage get usFlag => const AssetGenImage('assets/images/us_flag.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    fainzyLogo,
    fainzyRobot,
    jpFlag,
    loading,
    robos,
    robot1,
    roby,
    testFood,
    testRestaurant,
    usFlag,
  ];
}

class $AssetsLottiesGen {
  const $AssetsLottiesGen();

  /// File path: assets/lotties/error.json
  LottieGenImage get error => const LottieGenImage('assets/lotties/error.json');

  /// File path: assets/lotties/info.json
  LottieGenImage get info => const LottieGenImage('assets/lotties/info.json');

  /// File path: assets/lotties/success.json
  LottieGenImage get success =>
      const LottieGenImage('assets/lotties/success.json');

  /// List of all assets
  List<LottieGenImage> get values => [error, info, success];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/accept_order_ENG.wav
  String get acceptOrderENG => 'assets/sounds/accept_order_ENG.wav';

  /// File path: assets/sounds/accept_order_JAP.wav
  String get acceptOrderJAP => 'assets/sounds/accept_order_JAP.wav';

  /// File path: assets/sounds/payment_confirmed_ENG.mp3
  String get paymentConfirmedENG => 'assets/sounds/payment_confirmed_ENG.mp3';

  /// File path: assets/sounds/payment_confirmed_JAP.mp3
  String get paymentConfirmedJAP => 'assets/sounds/payment_confirmed_JAP.mp3';

  /// File path: assets/sounds/payment_confirmed_combined.mp3
  String get paymentConfirmedCombined =>
      'assets/sounds/payment_confirmed_combined.mp3';

  /// File path: assets/sounds/robot_arrived_for_dropoff_ENG.wav
  String get robotArrivedForDropoffENG =>
      'assets/sounds/robot_arrived_for_dropoff_ENG.wav';

  /// File path: assets/sounds/robot_arrived_for_dropoff_JAP.wav
  String get robotArrivedForDropoffJAP =>
      'assets/sounds/robot_arrived_for_dropoff_JAP.wav';

  /// File path: assets/sounds/robot_arrived_for_pickup_ENG.wav
  String get robotArrivedForPickupENG =>
      'assets/sounds/robot_arrived_for_pickup_ENG.wav';

  /// File path: assets/sounds/robot_arrived_for_pickup_JAP.wav
  String get robotArrivedForPickupJAP =>
      'assets/sounds/robot_arrived_for_pickup_JAP.wav';

  /// List of all assets
  List<String> get values => [
    acceptOrderENG,
    acceptOrderJAP,
    paymentConfirmedENG,
    paymentConfirmedJAP,
    paymentConfirmedCombined,
    robotArrivedForDropoffENG,
    robotArrivedForDropoffJAP,
    robotArrivedForPickupENG,
    robotArrivedForPickupJAP,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLottiesGen lotties = $AssetsLottiesGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
