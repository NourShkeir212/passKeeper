import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../sign_up/sign_up_screen.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onOnboardingDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    NavigationService.pushReplacement(const SignUpScreen());
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headlineSmall!,
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!,
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      bodyPadding: const EdgeInsets.all(24.0),
    );

    return SafeArea( // Wrap with SafeArea
      child: IntroductionScreen(
        pages: [
          PageViewModel(
            title: AppLocalizations.of(context)!.onboardingPage1Title,
            body: AppLocalizations.of(context)!.onboardingPage1Body,
            image: _buildImage(context, 'onboarding_secure'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: AppLocalizations.of(context)!.onboardingPage2Title,
            body: AppLocalizations.of(context)!.onboardingPage2Body,
            image: _buildImage(context, 'onboarding_organize'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: AppLocalizations.of(context)!.onboardingPage3Title,
            body: AppLocalizations.of(context)!.onboardingPage3Body,
            image: _buildImage(context, 'onboarding_access'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: AppLocalizations.of(context)!.onboardingPage4Title,
            body: AppLocalizations.of(context)!.onboardingPage4Body,
            image: _buildImage(context, 'decoy'), // Use your new SVG base name
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onOnboardingDone(context),
        showSkipButton: true,
        skip: Text(AppLocalizations.of(context)!.onboardingSkipButton, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
        next: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
        done: Text(AppLocalizations.of(context)!.onboardingDoneButton, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),

        controlsPadding: const EdgeInsets.all(16.0),

        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.primary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String baseAssetName) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fullAssetName = 'assets/svg/on_boarding/${baseAssetName}${isDarkMode ? "_dark" : "_light"}.svg';
    return SvgPicture.asset(fullAssetName, width: 250);
  }
}