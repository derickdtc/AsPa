import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // --- Brand Colors (Light) ---
      primary: Color(0xffc62828),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffebee), // Mapeado do "Alternate"
      onPrimaryContainer: Color(0xff212121), // Contraste no Alternate

      secondary: Color(0xffff746c),
      onSecondary: Color(
          0xffffffff), // ou 0xff000000 dependendo da preferência de leitura
      secondaryContainer:
          Color(0xffffdad6), // Gerado/Aproximado para manter harmonia
      onSecondaryContainer: Color(0xff2c3e50),

      tertiary: Color(0xff2e7d32),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbcf0b4), // Gerado/Aproximado
      onTertiaryContainer: Color(0xff002204),

      // --- Semantic Colors (Light) ---
      error: Color(0xffff5963),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad9),
      onErrorContainer: Color(0xff410002),

      // --- Utility Colors (Light) ---
      surface: Color(0xffffffff), // Primary Background
      onSurface: Color(0xff212121), // Primary Text
      onSurfaceVariant: Color(0xff2c3e50), // Secondary Text

      outline: Color(0xff857371),
      outlineVariant: Color(0xffd8c2bf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313033),
      inversePrimary: Color(0xffffb4a9),

      // Mapeando Secondary Background para os containers de superfície
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f5f5), // Secondary Background
      surfaceContainer: Color(0xfff5f5f5), // Secondary Background
      surfaceContainerHigh: Color(0xffececec),
      surfaceContainerHighest: Color(0xffe6e6e6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      // --- Brand Colors (Dark) ---
      primary: Color(0xffef5350),
      onPrimary:
          Color(0xff000000), // Texto escuro em cor primária clara fica melhor
      primaryContainer: Color(0xff3e2723), // Mapeado do "Alternate" Dark
      onPrimaryContainer: Color(0xffffdad4),

      secondary: Color(0xffffab91),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff73332f),
      onSecondaryContainer: Color(0xffffdad6),

      tertiary: Color(0xff81c784),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff00531a),
      onTertiaryContainer: Color(0xff9df69d),

      // --- Semantic Colors (Dark) ---
      error: Color(
          0xffff5963), // Mantido o mesmo, mas o Semantic Error é brilhante o suficiente
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),

      // --- Utility Colors (Dark) ---
      surface: Color(0xff121212), // Primary Background Dark
      onSurface: Color(0xffe0e0e0), // Primary Text Dark
      onSurfaceVariant:
          Color(0xffe0e0e0), // Secondary Text Dark (Imagem usa o mesmo)

      outline: Color(0xffa08c8a),
      outlineVariant: Color(0xff534341),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e5),
      inversePrimary: Color(0xffc62828),

      // Mapeando Secondary Background Dark
      surfaceContainerLowest: Color(0xff0f0f0f),
      surfaceContainerLow: Color(0xff1e1e1e), // Secondary Background Dark
      surfaceContainer: Color(0xff1e1e1e), // Secondary Background Dark
      surfaceContainerHigh: Color(0xff2b2b2b),
      surfaceContainerHighest: Color(0xff363636),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  // Mantive os esquemas de contraste gerados pelo Material original,
  // mas ajustei o principal (primary) para não quebrar a consistência
  // se você decidir usá-los. Se não usar, pode ignorar essas funções abaixo.

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xffa61b1b), // Versão mais escura do #c62828
      surfaceTint: Color(0xffc62828),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffebee),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffa83e38),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad6),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff0f5e18),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbcf0b4),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xff8c1d18),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad9),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xffffffff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff482926),
      outlineVariant: Color(0xff664542),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313033),
      inversePrimary: Color(0xffffb4a9),
      primaryFixed: Color(0xffdf3734),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xffbe1d1e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffdf3734),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xffbe1d1e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4a964a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff307c33),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffded8e1),
      surfaceBright: Color(0xfffdf8fd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2fa),
      surfaceContainer: Color(0xfff1ecf4),
      surfaceContainerHigh: Color(0xffebe6ee),
      surfaceContainerHighest: Color(0xffe6e1e9),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff630007),
      surfaceTint: Color(0xffc62828),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa61b1b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff630007),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa83e38),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003405),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0f5e18),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c1d18),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xffffffff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff270d0b),
      outlineVariant: Color(0xff482926),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313033),
      inversePrimary: Color(0xffffb4a9),
      primaryFixed: Color(0xffa61b1b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff80000b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa61b1b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff80000b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff0f5e18),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff004609),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffded8e1),
      surfaceBright: Color(0xfffdf8fd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2fa),
      surfaceContainer: Color(0xfff1ecf4),
      surfaceContainerHigh: Color(0xffebe6ee),
      surfaceContainerHighest: Color(0xffe6e1e9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2cd),
      surfaceTint: Color(0xffef5350),
      onPrimary: Color(0xff3f0003),
      primaryContainer: Color(0xffff5449),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2cd),
      onSecondary: Color(0xff3f0003),
      secondaryContainer: Color(0xffff9082),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbcf0b4),
      onTertiary: Color(0xff002b07),
      tertiaryContainer: Color(0xff81c784),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121212),
      onSurface: Color(0xfffff9f9),
      onSurfaceVariant: Color(0xffdacfd0),
      outline: Color(0xffb1a6a6),
      outlineVariant: Color(0xff908687),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e5),
      inversePrimary: Color(0xffc00010),
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
      surfaceDim: Color(0xff141316),
      surfaceBright: Color(0xff3a383c),
      surfaceContainerLowest: Color(0xff0f0e11),
      surfaceContainerLow: Color(0xff1d1b1e),
      surfaceContainer: Color(0xff211f22),
      surfaceContainerHigh: Color(0xff2b292d),
      surfaceContainerHighest: Color(0xff363438),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff9f9),
      surfaceTint: Color(0xffef5350),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffbab1),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9f9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffbab1),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff0ffeb),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffbcf0b4),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121212),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffff9f9),
      outline: Color(0xffdacfd0),
      outlineVariant: Color(0xffdacfd0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e1e5),
      inversePrimary: Color(0xff9c000a),
      primaryFixed: Color(0xffffe0db),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffbab1),
      onPrimaryFixedVariant: Color(0xff2c0102),
      secondaryFixed: Color(0xffffe0db),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffbab1),
      onSecondaryFixedVariant: Color(0xff2c0102),
      tertiaryFixed: Color(0xffc5facd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffbcf0b4),
      onTertiaryFixedVariant: Color(0xff001602),
      surfaceDim: Color(0xff141316),
      surfaceBright: Color(0xff3a383c),
      surfaceContainerLowest: Color(0xff0f0e11),
      surfaceContainerLow: Color(0xff1d1b1e),
      surfaceContainer: Color(0xff211f22),
      surfaceContainerHigh: Color(0xff2b292d),
      surfaceContainerHighest: Color(0xff363438),
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
