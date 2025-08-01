import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../model/account_model.dart';

class AccountCard extends StatefulWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.label_important_outline, size: 20),
                  const SizedBox(width: 8),
                  CustomText(
                    widget.account.serviceName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                context,
                icon: Icons.person_outline,
                text: widget.account.username,
              ),
              const SizedBox(height: 12),
              _buildPasswordRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(text),
        ),
      ],
    );
  }

  Widget _buildPasswordRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lock_outline,
            size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            _isPasswordVisible ? widget.account.password : '••••••••••',
            style: const TextStyle(
                fontFamily: 'monospace', letterSpacing: 1.5, fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          splashRadius: 20,
        ),
      ],
    );
  }
}