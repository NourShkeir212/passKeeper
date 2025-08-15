import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:secure_accounts/core/theme/app_icons.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';

import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/app_title_name.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../home/home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt to authenticate immediately when the screen loads
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    final isAuthenticated = await BiometricService.authenticate(context);
    if (isAuthenticated && mounted) {
      // If successful, navigate to the home page
      NavigationService.pushAndRemoveUntil(const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                'assets/icon/logo/logo.png',
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: AppLocalizations.of(context)!.localeName=="en",
                    child: AppTitleNameWidget()
                  ),
                  if(AppLocalizations.of(context)!.localeName=="en")
                  SizedBox(width: 10,),
                  CustomText(
                    maxLines: 2,
                    AppLocalizations.of(context)!.lockScreenTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if(AppLocalizations.of(context)!.localeName=="ar")
                    SizedBox(width: 10,),
                  Visibility(
                    visible: AppLocalizations.of(context)!.localeName=="ar",
                    child: AppTitleNameWidget()
                  ),
                ],
              )
            ),
            const SizedBox(height: 8),
             CustomText(AppLocalizations.of(context)!.lockScreenSubtitle,),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _authenticateUser,
              icon: const Icon(AppIcons.fingerprint),
              label:  Text(AppLocalizations.of(context)!.unlockButton),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}