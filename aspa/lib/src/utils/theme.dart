import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff904a44),
      surfaceTint: Color(0xff904a44),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad6),
      onPrimaryContainer: Color(0xff73332e),
      secondary: Color(0xff904a45),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad6),
      onSecondaryContainer: Color(0xff73332f),
      tertiary: Color(0xff3c6939),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbcf0b4),
      onTertiaryContainer: Color(0xff245024),
      error: Color(0xff904a4b),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad9),
      onErrorContainer: Color(0xff733335),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff231918),
      onSurfaceVariant: Color(0xff534341),
      outline: Color(0xff857371),
      outlineVariant: Color(0xffd8c2bf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inversePrimary: Color(0xffffb4ac),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff3b0908),
      primaryFixedDim: Color(0xffffb4ac),
      onPrimaryFixedVariant: Color(0xff73332e),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff3b0908),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff73332f),
      tertiaryFixed: Color(0xffbcf0b4),
      onTertiaryFixed: Color(0xff002204),
      tertiaryFixedDim: Color(0xffa1d39a),
      onTertiaryFixedVariant: Color(0xff245024),
      surfaceDim: Color(0xffe8d6d4),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfffceae8),
      surfaceContainerHigh: Color(0xfff6e4e2),
      surfaceContainerHighest: Color(0xfff1dedc),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5e231f),
      surfaceTint: Color(0xff904a44),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa15852),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff5e2320),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa15853),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff123f14),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4a7847),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e2325),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa15859),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff180f0e),
      onSurfaceVariant: Color(0xff413331),
      outline: Color(0xff5f4f4d),
      outlineVariant: Color(0xff7b6967),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inversePrimary: Color(0xffffb4ac),
      primaryFixed: Color(0xffa15852),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff84413b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa15853),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff84413c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4a7847),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff325f30),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd4c3c1),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ef),
      surfaceContainer: Color(0xfff6e4e2),
      surfaceContainerHigh: Color(0xffebd9d7),
      surfaceContainerHighest: Color(0xffdfcecc),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff511a16),
      surfaceTint: Color(0xff904a44),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff763631),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff511917),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff763632),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff05340b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff265326),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff51191c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff763537),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff362927),
      outlineVariant: Color(0xff554544),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e2d),
      inversePrimary: Color(0xffffb4ac),
      primaryFixed: Color(0xff763631),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff59201c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff763632),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff59201d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff265326),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0d3b11),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6b5b3),
      surfaceBright: Color(0xfffff8f7),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffedea),
      surfaceContainer: Color(0xfff1dedc),
      surfaceContainerHigh: Color(0xffe2d0ce),
      surfaceContainerHighest: Color(0xffd4c3c1),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4ac),
      surfaceTint: Color(0xffffb4ac),
      onPrimary: Color(0xff561e1a),
      primaryContainer: Color(0xff73332e),
      onPrimaryContainer: Color(0xffffdad6),
      secondary: Color(0xffffb3ad),
      onSecondary: Color(0xff571e1b),
      secondaryContainer: Color(0xff73332f),
      onSecondaryContainer: Color(0xffffdad6),
      tertiary: Color(0xffa1d39a),
      onTertiary: Color(0xff0a390f),
      tertiaryContainer: Color(0xff245024),
      onTertiaryContainer: Color(0xffbcf0b4),
      error: Color(0xffffb3b2),
      onError: Color(0xff561d20),
      errorContainer: Color(0xff733335),
      onErrorContainer: Color(0xffffdad9),
      surface: Color(0xff1a1110),
      onSurface: Color(0xfff1dedc),
      onSurfaceVariant: Color(0xffd8c2bf),
      outline: Color(0xffa08c8a),
      outlineVariant: Color(0xff534341),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inversePrimary: Color(0xff904a44),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff3b0908),
      primaryFixedDim: Color(0xffffb4ac),
      onPrimaryFixedVariant: Color(0xff73332e),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff3b0908),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff73332f),
      tertiaryFixed: Color(0xffbcf0b4),
      onTertiaryFixed: Color(0xff002204),
      tertiaryFixedDim: Color(0xffa1d39a),
      onTertiaryFixedVariant: Color(0xff245024),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff423735),
      surfaceContainerLowest: Color(0xff140c0b),
      surfaceContainerLow: Color(0xff231918),
      surfaceContainer: Color(0xff271d1c),
      surfaceContainerHigh: Color(0xff322826),
      surfaceContainerHighest: Color(0xff3d3231),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2cd),
      surfaceTint: Color(0xffffb4ac),
      onPrimary: Color(0xff481310),
      primaryContainer: Color(0xffcc7b73),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2ce),
      onSecondary: Color(0xff481311),
      secondaryContainer: Color(0xffcc7b74),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffb6eaae),
      onTertiary: Color(0xff002d06),
      tertiaryContainer: Color(0xff6d9c67),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2d0),
      onError: Color(0xff481216),
      errorContainer: Color(0xffcb7a7b),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a1110),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffeed7d5),
      outline: Color(0xffc2adab),
      outlineVariant: Color(0xff9f8c8a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inversePrimary: Color(0xff74352f),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff2c0102),
      primaryFixedDim: Color(0xffffb4ac),
      onPrimaryFixedVariant: Color(0xff5e231f),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff2c0102),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff5e2320),
      tertiaryFixed: Color(0xffbcf0b4),
      onTertiaryFixed: Color(0xff001602),
      tertiaryFixedDim: Color(0xffa1d39a),
      onTertiaryFixedVariant: Color(0xff123f14),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff4d4240),
      surfaceContainerLowest: Color(0xff0d0605),
      surfaceContainerLow: Color(0xff251b1a),
      surfaceContainer: Color(0xff302524),
      surfaceContainerHigh: Color(0xff3b302f),
      surfaceContainerHighest: Color(0xff463b3a),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece9),
      surfaceTint: Color(0xffffb4ac),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaea6),
      onPrimaryContainer: Color(0xff220001),
      secondary: Color(0xffffecea),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffaea7),
      onSecondaryContainer: Color(0xff220001),
      tertiary: Color(0xffcafec0),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff9dcf96),
      onTertiaryContainer: Color(0xff000f01),
      error: Color(0xffffeceb),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffadad),
      onErrorContainer: Color(0xff220003),
      surface: Color(0xff1a1110),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece9),
      outlineVariant: Color(0xffd4bebb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff1dedc),
      inversePrimary: Color(0xff74352f),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4ac),
      onPrimaryFixedVariant: Color(0xff2c0102),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb3ad),
      onSecondaryFixedVariant: Color(0xff2c0102),
      tertiaryFixed: Color(0xffbcf0b4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa1d39a),
      onTertiaryFixedVariant: Color(0xff001602),
      surfaceDim: Color(0xff1a1110),
      surfaceBright: Color(0xff5a4d4c),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff271d1c),
      surfaceContainer: Color(0xff392e2d),
      surfaceContainerHigh: Color(0xff443938),
      surfaceContainerHighest: Color(0xff504443),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
