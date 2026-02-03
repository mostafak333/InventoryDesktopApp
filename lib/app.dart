import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'features/auth/presentation/login_page.dart';

class InventoryApp extends ConsumerWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate, // <--- Add your custom delegate here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginPage());
    /*  home: MainLayout(
        child: Center(
          child: Builder( // Use Builder to get the correct context
            builder: (context) {
              return Text(
                // Use the translate method instead of hardcoded 'Welcome'
                AppLocalizations.of(context)?.translate('welcome') ?? 'Welcome',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
        ),
      ),
    );*/
  }
}
