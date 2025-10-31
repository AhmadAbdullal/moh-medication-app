import 'package:flutter/material.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('loginTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: localizations.translate('emailField'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: localizations.translate('passwordField'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
              },
              child: Text(localizations.translate('loginTitle')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.registerRoute);
              },
              child: Text(localizations.translate('registerTitle')),
            ),
          ],
        ),
      ),
    );
  }
}
