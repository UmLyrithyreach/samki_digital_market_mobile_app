import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SamkiAppBar(title: 'About Us', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: SamkiTheme.accentLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SAMKI',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: SamkiTheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Digital Market',
                    style: TextStyle(
                      fontSize: 16,
                      color: SamkiTheme.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cambodia\'s trusted skincare marketplace connecting buyers with verified sellers.',
                    style: TextStyle(
                      fontSize: 15,
                      color: SamkiTheme.secondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Stats
            const Row(
              children: [
                _Stat(value: '30+', label: 'Products'),
                SizedBox(width: 12),
                _Stat(value: '3+', label: 'Verified Sellers'),
                SizedBox(width: 12),
                _Stat(value: '6', label: 'Categories'),
              ],
            ),

            const SizedBox(height: 28),
            const Text(
              'Our Mission',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SamkiTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'At SAMKI, we believe everyone deserves access to authentic, quality skincare. We connect Cambodian buyers with trusted local sellers offering genuine products — verified, curated, and delivered to your door.',
              style: TextStyle(
                  fontSize: 14, color: SamkiTheme.secondary, height: 1.7),
            ),

            const SizedBox(height: 28),
            const Text(
              'Contact Us',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SamkiTheme.primary),
            ),
            const SizedBox(height: 12),
            const _ContactRow(icon: Icons.email_outlined, label: 'hello@samki.com.kh'),
            const SizedBox(height: 8),
            const _ContactRow(
                icon: Icons.location_on_outlined, label: 'Phnom Penh, Cambodia'),
            const SizedBox(height: 8),
            const _ContactRow(
                icon: Icons.phone_outlined, label: '+855 12 345 678'),

            const SizedBox(height: 28),
            const Text(
              'Our Sellers',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SamkiTheme.primary),
            ),
            const SizedBox(height: 12),
            ...['GlowLab Skincare', 'PureSkin Co.', 'DermaLuxe'].map(
              (seller) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SamkiTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SamkiTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: SamkiTheme.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          seller[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: SamkiTheme.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(seller,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.verified,
                        size: 16, color: SamkiTheme.accent),
                    const SizedBox(width: 4),
                    const Text('Verified',
                        style: TextStyle(
                            fontSize: 11,
                            color: SamkiTheme.accent,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: SamkiTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SamkiTheme.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: SamkiTheme.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: SamkiTheme.secondary)),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SamkiTheme.accent),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 14, color: SamkiTheme.secondary)),
      ],
    );
  }
}
