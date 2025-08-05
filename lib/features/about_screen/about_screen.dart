import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:secure_accounts/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/custom_text.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Helper function to launch URLs
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.aboutScreenTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            Icon(
              AppIcons.shield,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            CustomText(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            CustomText(
              AppLocalizations.of(context)!.aboutScreenVersion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
             CustomText(
             AppLocalizations.of(context)!.aboutScreenDescription,
              textAlign: TextAlign.center,
               maxLines: 6,
            ),
            const Divider(height: 48),

            // Contact Info
             _SectionTitle(title: AppLocalizations.of(context)!.aboutScreenContactTitle),
            const SizedBox(height: 16),
            _ContactTile(
              icon: AppIcons.email,
              title: AppLocalizations.of(context)!.aboutScreenContactEmail,
              subtitle: "mohammednourshkeir@gmail.com",
              onTap: () => _launchURL("mailto:mohammednourshkeir@gmail.com"),
            ),
            _ContactTile(
              icon: Iconsax.facebook,
              title: AppLocalizations.of(context)!.aboutScreenContactFacebook,
              subtitle: "Mohammad Nour Shkeir",
              onTap: () => _launchURL("https://www.facebook.com/mhdnourshkeir"),
            ),
            _ContactTile(
              icon: Iconsax.whatsapp,
              title: AppLocalizations.of(context)!.aboutScreenContactWhatsApp,
              subtitle: "+963 962 762 819", // Replace with your number
              onTap: () => _launchURL("https://wa.me/963962762819"),
            ),

          ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.5),
        ),
      ),
    );
  }
}

// Helper widget for section titles
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

// Helper widget for contact list tiles
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: CustomText(title,),
      subtitle: CustomText(subtitle, style: Theme.of(context).textTheme.bodySmall,maxLines: 2,),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}