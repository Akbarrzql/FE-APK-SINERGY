// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Poppins-Black.ttf
  String get poppinsBlack => 'assets/fonts/Poppins-Black.ttf';

  /// File path: assets/fonts/Poppins-BlackItalic.ttf
  String get poppinsBlackItalic => 'assets/fonts/Poppins-BlackItalic.ttf';

  /// File path: assets/fonts/Poppins-Bold.ttf
  String get poppinsBold => 'assets/fonts/Poppins-Bold.ttf';

  /// File path: assets/fonts/Poppins-BoldItalic.ttf
  String get poppinsBoldItalic => 'assets/fonts/Poppins-BoldItalic.ttf';

  /// File path: assets/fonts/Poppins-ExtraBold.ttf
  String get poppinsExtraBold => 'assets/fonts/Poppins-ExtraBold.ttf';

  /// File path: assets/fonts/Poppins-ExtraBoldItalic.ttf
  String get poppinsExtraBoldItalic =>
      'assets/fonts/Poppins-ExtraBoldItalic.ttf';

  /// File path: assets/fonts/Poppins-ExtraLight.ttf
  String get poppinsExtraLight => 'assets/fonts/Poppins-ExtraLight.ttf';

  /// File path: assets/fonts/Poppins-ExtraLightItalic.ttf
  String get poppinsExtraLightItalic =>
      'assets/fonts/Poppins-ExtraLightItalic.ttf';

  /// File path: assets/fonts/Poppins-Italic.ttf
  String get poppinsItalic => 'assets/fonts/Poppins-Italic.ttf';

  /// File path: assets/fonts/Poppins-Light.ttf
  String get poppinsLight => 'assets/fonts/Poppins-Light.ttf';

  /// File path: assets/fonts/Poppins-LightItalic.ttf
  String get poppinsLightItalic => 'assets/fonts/Poppins-LightItalic.ttf';

  /// File path: assets/fonts/Poppins-Medium.ttf
  String get poppinsMedium => 'assets/fonts/Poppins-Medium.ttf';

  /// File path: assets/fonts/Poppins-MediumItalic.ttf
  String get poppinsMediumItalic => 'assets/fonts/Poppins-MediumItalic.ttf';

  /// File path: assets/fonts/Poppins-Regular.ttf
  String get poppinsRegular => 'assets/fonts/Poppins-Regular.ttf';

  /// File path: assets/fonts/Poppins-SemiBold.ttf
  String get poppinsSemiBold => 'assets/fonts/Poppins-SemiBold.ttf';

  /// File path: assets/fonts/Poppins-SemiBoldItalic.ttf
  String get poppinsSemiBoldItalic => 'assets/fonts/Poppins-SemiBoldItalic.ttf';

  /// File path: assets/fonts/Poppins-Thin.ttf
  String get poppinsThin => 'assets/fonts/Poppins-Thin.ttf';

  /// File path: assets/fonts/Poppins-ThinItalic.ttf
  String get poppinsThinItalic => 'assets/fonts/Poppins-ThinItalic.ttf';

  /// List of all assets
  List<String> get values => [
    poppinsBlack,
    poppinsBlackItalic,
    poppinsBold,
    poppinsBoldItalic,
    poppinsExtraBold,
    poppinsExtraBoldItalic,
    poppinsExtraLight,
    poppinsExtraLightItalic,
    poppinsItalic,
    poppinsLight,
    poppinsLightItalic,
    poppinsMedium,
    poppinsMediumItalic,
    poppinsRegular,
    poppinsSemiBold,
    poppinsSemiBoldItalic,
    poppinsThin,
    poppinsThinItalic,
  ];
}

class $AssetsImageGen {
  const $AssetsImageGen();

  /// Directory path: assets/image/png
  $AssetsImagePngGen get png => const $AssetsImagePngGen();

  /// Directory path: assets/image/svg
  $AssetsImageSvgGen get svg => const $AssetsImageSvgGen();
}

class $AssetsImagePngGen {
  const $AssetsImagePngGen();

  /// File path: assets/image/png/gabungyuk_logo.png
  AssetGenImage get gabungyukLogo =>
      const AssetGenImage('assets/image/png/gabungyuk_logo.png');

  /// File path: assets/image/png/kolaborasi_onboarding.png
  AssetGenImage get kolaborasiOnboarding =>
      const AssetGenImage('assets/image/png/kolaborasi_onboarding.png');

  /// File path: assets/image/png/mentor_onboarding.png
  AssetGenImage get mentorOnboarding =>
      const AssetGenImage('assets/image/png/mentor_onboarding.png');

  /// File path: assets/image/png/portrait-fashion-model-girl-studio-130864352.webp
  AssetGenImage get portraitFashionModelGirlStudio130864352 =>
      const AssetGenImage(
        'assets/image/png/portrait-fashion-model-girl-studio-130864352.webp',
      );

  /// File path: assets/image/png/rekomendasi_onboarding.png
  AssetGenImage get rekomendasiOnboarding =>
      const AssetGenImage('assets/image/png/rekomendasi_onboarding.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    gabungyukLogo,
    kolaborasiOnboarding,
    mentorOnboarding,
    portraitFashionModelGirlStudio130864352,
    rekomendasiOnboarding,
  ];
}

class $AssetsImageSvgGen {
  const $AssetsImageSvgGen();

  /// File path: assets/image/svg/logo_gabungyuk.svg
  SvgGenImage get logoGabungyuk =>
      const SvgGenImage('assets/image/svg/logo_gabungyuk.svg');

  /// List of all assets
  List<SvgGenImage> get values => [logoGabungyuk];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImageGen image = $AssetsImageGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

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

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
