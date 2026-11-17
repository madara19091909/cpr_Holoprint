import 'package:material_ui/material_ui.dart';

import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CprHoloprintApp());
}

class CprHoloprintApp extends StatelessWidget {
  const CprHoloprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF43D6BD);
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF111A22),
    );

    return MaterialApp(
      title: 'CPR Holoprint',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0A1118),
        cardColor: const Color(0xFF111A22),
        dividerColor: Colors.white.withValues(alpha: 0.08),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1118),
          foregroundColor: Color(0xFFF2F7F7),
          centerTitle: false,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0E1720),
          indicatorColor: seed.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17232D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}
