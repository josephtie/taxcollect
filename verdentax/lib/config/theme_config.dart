import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';

class AppTheme {
  // Charte graphique
  static const Color inkColor = Color(0xFF1F1F1F); // Noir profond
  static const Color goldColor = Color(0xFFD4A017); // Or / jaune doré

  static const Color primaryColor = inkColor;
  static const Color secondaryColor = goldColor;
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = inkColor;
  static const Color onPrimaryColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        onPrimary: onPrimaryColor,
        error: errorColor,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: onPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: inkColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkColor,
          side: const BorderSide(color: goldColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: goldColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: Color(0xFF757575)),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        errorStyle: const TextStyle(color: errorColor),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldColor,
        foregroundColor: inkColor,
        elevation: 4,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: goldColor,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: onSurfaceColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: const TextStyle(color: surfaceColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Text Theme - Titres: Montserrat Bold / Texte: Inter (repli Aptos/Calibri indisponibles sur mobile)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF757575),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF757575),
        ),
      ),
    );
  }

  // Dark Theme (optional implementation)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        onPrimary: onPrimaryColor,
        error: errorColor,
      ),
      // Add dark theme customizations here if needed
    );
  }

  // Custom Colors
  static Color getStatusColor(String status) {
    switch (status) {
      case AppConfig.statusValidee:
        return successColor;
      case AppConfig.statusEnAttente:
        return warningColor;
      case AppConfig.statusAnnulee:
      case AppConfig.statusEnErreur:
        return errorColor;
      case AppConfig.statusSynchronisee:
        return primaryColor;
      default:
        return const Color(0xFF757575);
    }
  }

  static Color getPaymentMethodColor(String method) {
    switch (method) {
      case AppConfig.paiementEspece:
        return successColor;
      case AppConfig.paiementMobileMoney:
        return primaryColor;
      case AppConfig.paiementQRCode:
        return secondaryColor;
      default:
        return const Color(0xFF757575);
    }
  }

  static Color getClotureStatusColor(String status) {
    switch (status) {
      case AppConfig.clotureValidee:
        return successColor;
      case AppConfig.clotureSoumise:
        return warningColor;
      case AppConfig.clotureRejetee:
        return errorColor;
      case AppConfig.clotureDeposee:
        return primaryColor;
      case AppConfig.clotureEnCours:
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }
}
