import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'viewer/presentation/screens/viewer_screen.dart';

class OivApp extends StatelessWidget {
  const OivApp({super.key, this.initialArguments = const []});

  final List<String> initialArguments;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.darkTheme,
      builder: (context, child) => ColoredBox(
        color: AppColors.windowBackdrop,
        child: child ?? const SizedBox.shrink(),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ViewerScreen(initialArguments: initialArguments),
    );
  }
}
