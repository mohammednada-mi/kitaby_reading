import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/screens/home_screen.dart';
import 'package:kitaby_flutter/screens/add_book_screen.dart';
import 'package:kitaby_flutter/screens/add_challenge_screen.dart';
import 'package:kitaby_flutter/screens/category_screen.dart';
import 'package:kitaby_flutter/screens/challenges_screen.dart';
import 'package:kitaby_flutter/utils/constants.dart'; // Assuming constants are defined here
import 'package:kitaby_flutter/models/book.dart'; // Import BookCategory
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Import generated localization delegate
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void
main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  runApp(
    const KitabyApp(),
  );
}

class KitabyApp
    extends
        StatelessWidget {
  const KitabyApp({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    // Define the light theme based on the Next.js CSS variables
    final ThemeData
    lightTheme = ThemeData(
      brightness:
          Brightness.light,
      primaryColor: const Color(
        0xFF000000,
      ), // primary: 0 0% 9%; (Approx Black)
      colorScheme: ColorScheme.light(
        primary: const Color(
          0xFF000000,
        ), // primary: 0 0% 9%;
        onPrimary: const Color(
          0xFFFAFAFA,
        ), // primary-foreground: 0 0% 98%;
        secondary: const Color(
          0xFF737373,
        ), // Using muted-foreground for secondary text/icons
        onSecondary: const Color(
          0xFF171717,
        ), // secondary-foreground: 0 0% 9%;
        background: const Color(
          0xFFFFFFFF,
        ), // background: 0 0% 100%; (White)
        onBackground: const Color(
          0xFF0A0A0A,
        ), // foreground: 0 0% 3.9%; (Near Black)
        surface: const Color(
          0xFFFFFFFF,
        ), // card: 0 0% 100%; (White)
        onSurface: const Color(
          0xFF0A0A0A,
        ), // card-foreground: 0 0% 3.9%;
        error: const Color(
          0xFFDC2626,
        ), // destructive: 0 84.2% 60.2%; (Red)
        onError: const Color(
          0xFFFAFAFA,
        ), // destructive-foreground: 0 0% 98%;
        tertiary: const Color(
          0xFFFD984E,
        ), // accent: 26 100% 66%; (Warm Orange) - Approx.
        onTertiary: const Color(
          0xFFFFFFFF,
        ), // accent-foreground: 0 0% 100%;
        outline: const Color(
          0xFFE5E5E5,
        ), // border: 0 0% 89.8%;
        surfaceVariant: const Color(
          0xFFE0EAF6,
        ), // secondary: Soft blue used for card backgrounds etc.
        onSurfaceVariant: const Color(
          0xFF171717,
        ), // secondary-foreground
        inverseSurface: const Color(
          0xFFE0EAF6,
        ), // muted: Soft blue for muted backgrounds
        onInverseSurface: const Color(
          0xFF737373,
        ), // muted-foreground: Grey
      ),
      scaffoldBackgroundColor: const Color(
        0xFFFFFFFF,
      ), // background
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(
          0xFFFFFFFF,
        ), // background
        foregroundColor: Color(
          0xFF0A0A0A,
        ), // foreground
        elevation:
            1, // Add subtle elevation
        shadowColor:
            Colors.black26,
        iconTheme: IconThemeData(
          color: Color(
            0xFF0A0A0A,
          ),
        ),
        titleTextStyle: TextStyle(
          // Use GoogleFonts here if needed directly
          fontFamily:
              'Cairo', // Explicitly set font family
          color: Color(
            0xFF0A0A0A,
          ),
          fontSize:
              20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(
          0xFFFFFFFF,
        ), // card
        shadowColor: Colors.grey.withOpacity(
          0.15,
        ),
        elevation:
            1, // Subtle elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius,
          ), // Use defined radius
          side: const BorderSide(
            color: Color(
              0xFFE5E5E5,
            ),
          ), // border
        ),
        margin: const EdgeInsets.symmetric(
          vertical:
              AppConstants.spacingSmall /
              2,
        ), // Default card margin
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(
          0xFF000000,
        ), // primary
        linearTrackColor: Color(
          0xFFE0EAF6,
        ), // surfaceVariant (soft blue)
        circularTrackColor: Color(
          0xFFE0EAF6,
        ), // surfaceVariant (soft blue)
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:
            true,
        fillColor:
            Colors.grey[50], // Very light background for inputs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFFE5E5E5,
            ),
          ), // input border
        ),
        enabledBorder: OutlineInputBorder(
          // Border when not focused
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFFE5E5E5,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFFFD984E,
            ),
            width:
                1.5,
          ), // ring color (accent)
        ),
        labelStyle: TextStyle(
          color: const Color(
            0xFF737373,
          ).withOpacity(
            0.9,
          ),
        ), // muted-foreground approx
        hintStyle: const TextStyle(
          color: Color(
            0xFF737373,
          ),
        ), // muted-foreground approx
        contentPadding: const EdgeInsets.symmetric(
          horizontal:
              AppConstants.paddingMedium,
          vertical:
              AppConstants.paddingSmall *
              1.5,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius,
          ),
        ),
        buttonColor: const Color(
          0xFF000000,
        ), // primary
        textTheme:
            ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF000000,
          ), // primary
          foregroundColor: const Color(
            0xFFFAFAFA,
          ), // primary-foreground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal:
                AppConstants.paddingLarge,
            vertical:
                AppConstants.paddingMedium -
                2,
          ), // Adjust padding
          textStyle: const TextStyle(
            fontFamily:
                'Cairo',
            fontWeight:
                FontWeight.bold,
          ), // Ensure font
          elevation:
              2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(
            0xFF0A0A0A,
          ), // foreground
          side: const BorderSide(
            color: Color(
              0xFFE5E5E5,
            ),
          ), // input border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal:
                AppConstants.paddingLarge,
            vertical:
                AppConstants.paddingMedium -
                2,
          ), // Adjust padding
          textStyle: const TextStyle(
            fontFamily:
                'Cairo',
            fontWeight:
                FontWeight.normal,
          ), // Ensure font
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(
            0xFF000000,
          ), // primary
          textStyle: const TextStyle(
            fontFamily:
                'Cairo',
            fontWeight:
                FontWeight.bold,
          ), // Ensure font
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(
          0xFFE0EAF6,
        ), // secondary/muted
        labelStyle: TextStyle(
          color: const Color(
            0xFF171717,
          ).withOpacity(
            0.8,
          ),
          fontSize:
              11,
        ), // secondary-foreground
        padding: const EdgeInsets.symmetric(
          horizontal:
              8,
          vertical:
              2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadius *
                2,
          ), // More rounded
        ),
        side:
            BorderSide.none,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
            ThemeData.light().textTheme,
          )
          .copyWith(
            // Apply Cairo font globally and customize specific styles
            bodyLarge: TextStyle(
              color: const Color(
                0xFF0A0A0A,
              ).withOpacity(
                0.9,
              ),
              fontSize:
                  16,
              height:
                  1.4,
            ),
            bodyMedium: TextStyle(
              color: const Color(
                0xFF0A0A0A,
              ).withOpacity(
                0.8,
              ),
              fontSize:
                  14,
              height:
                  1.4,
            ),
            bodySmall: TextStyle(
              color: const Color(
                0xFF737373,
              ).withOpacity(
                0.9,
              ),
              fontSize:
                  12,
              height:
                  1.3,
            ), // muted-foreground
            titleLarge: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize:
                  22,
              color: Color(
                0xFF0A0A0A,
              ),
            ),
            titleMedium: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize:
                  18,
              color: Color(
                0xFF0A0A0A,
              ),
            ),
            titleSmall: const TextStyle(
              fontWeight:
                  FontWeight.w600,
              fontSize:
                  14,
              color: Color(
                0xFF0A0A0A,
              ),
            ), // Slightly less bold
            labelLarge: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize:
                  14,
              color: Color(
                0xFF0A0A0A,
              ),
            ), // For button text etc.
            labelMedium: const TextStyle(
              fontWeight:
                  FontWeight.w600,
              fontSize:
                  12,
              color: Color(
                0xFF0A0A0A,
              ),
            ),
            labelSmall: const TextStyle(
              fontWeight:
                  FontWeight.w500,
              fontSize:
                  11,
              color: Color(
                0xFF737373,
              ),
            ),
          )
          .apply(
            bodyColor: const Color(
              0xFF0A0A0A,
            ), // Default text color
            displayColor: const Color(
              0xFF0A0A0A,
            ),
          ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:
              Colors.black87, // Darker tooltip background
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusSmall,
          ),
        ),
        textStyle: const TextStyle(
          color:
              Colors.white,
          fontSize:
              12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal:
              8,
          vertical:
              4,
        ),
        waitDuration: const Duration(
          milliseconds:
              300,
        ), // Shorter wait time
      ),
      dividerTheme: DividerThemeData(
        color:
            Colors.grey.shade200, // Lighter divider
        thickness:
            1,
        space:
            1, // Minimal space
      ),
      // Add other theme properties as needed
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (
                _,
              ) =>
                  BookProvider(),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) =>
                  ChallengeProvider(),
        ),
      ],
      child: MaterialApp(
        title:
            'Kitaby', // Use appTitle from localization if set up
        theme:
            lightTheme,
        // Add dark theme if needed
        // darkTheme: darkTheme,
        // themeMode: ThemeMode.system, // Or ThemeMode.light / ThemeMode.dark

        // Localization Setup
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale(
            'ar',
            '',
          ), // Arabic
          Locale(
            'en',
            '',
          ), // English (optional fallback)
        ],
        locale: const Locale(
          'ar',
          '',
        ), // Set default locale to Arabic

        debugShowCheckedModeBanner:
            false,
        initialRoute:
            '/',
        routes: {
          '/':
              (
                context,
              ) =>
                  const HomeScreen(),
          '/add-book':
              (
                context,
              ) =>
                  const AddBookScreen(),
          '/add-challenge':
              (
                context,
              ) =>
                  const AddChallengeScreen(),
          // Remove '/category' route - handled by onGenerateRoute
          '/challenges':
              (
                context,
              ) =>
                  const ChallengesScreen(),
        },
        // Handle dynamic category routes
        onGenerateRoute: (
          settings,
        ) {
          if (settings.name !=
                  null &&
              settings.name!.startsWith(
                '/category/',
              )) {
            // Extract category from the route name (e.g., '/category/reading')
            final categoryString =
                settings.name!
                    .split(
                      '/',
                    )
                    .last;
            final category = bookCategoryFromString(
              categoryString,
            ); // Use helper
            return MaterialPageRoute(
              settings:
                  settings, // Pass settings for correct route identification
              builder:
                  (
                    context,
                  ) => CategoryScreen(
                    category:
                        category,
                  ),
            );
          }
          // Handle '/category' if arguments are passed (from drawer)
          if (settings.name ==
                  '/category' &&
              settings.arguments
                  is BookCategory) {
            final category =
                settings.arguments
                    as BookCategory;
            return MaterialPageRoute(
              settings:
                  settings,
              builder:
                  (
                    context,
                  ) => CategoryScreen(
                    category:
                        category,
                  ),
            );
          }
          // Handle other routes or unknown routes
          // You might want to navigate to a NotFoundScreen here
          return MaterialPageRoute(
            builder:
                (
                  context,
                ) => Scaffold(
                  appBar:
                      AppBar(),
                  body: const Center(
                    child: Text(
                      'Page not found',
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }
}
