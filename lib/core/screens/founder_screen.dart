import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// "About the Founder" screen — showcases the person behind WreckerLogix.
class FounderScreen extends StatelessWidget {
  const FounderScreen({super.key});

  static const _bgColor = Color(0xFF141414);
  static const _cardColor = Color(0xFF1E1E1E);
  static const _accentRed = Color(0xFFD32F2F);
  static const _textWhite = Color(0xFFEEEEEE);
  static const _textGray = Color(0xFFAAAAAA);
  static const _contactEmail = 'contact@wreckerlogix.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        foregroundColor: _textWhite,
        elevation: 0,
        title: const Text('About'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(),
                const SizedBox(height: 32),
                _buildFounderCard(context),
                const SizedBox(height: 36),
                _buildEmailRow(),
                const SizedBox(height: 24),
                _buildLetsTalkButton(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── Title ────────────────────────────

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 28,
          fontFamily: 'Roboto',
          color: _textWhite,
          height: 1.3,
        ),
        children: [
          TextSpan(text: "Built by a Founder Who's "),
          TextSpan(
            text: 'Done the Work',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Founder Card ─────────────────────

  Widget _buildFounderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: _accentRed, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          const CircleAvatar(
            radius: 36,
            backgroundColor: _accentRed,
            child: Text(
              'MW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Details
          Expanded(child: _buildCardDetails()),
        ],
      ),
    );
  }

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & title
        const Text(
          'Mike Ward',
          style: TextStyle(
            color: _textWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'FOUNDER & CEO',
          style: TextStyle(
            color: _accentRed,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Bullet points
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: const [
            _InfoChip(icon: Icons.construction, text: '25 years in the trades'),
            _InfoChip(icon: Icons.settings, text: 'Runs Apex Epoxy & Flooring LLC'),
            _InfoChip(icon: Icons.apartment, text: 'Manages 18 rental units'),
          ],
        ),
        const SizedBox(height: 10),
        const _InfoChip(
          icon: Icons.location_on,
          text: "Kokomo, Indiana \u2014 heart of America's trucking corridor",
        ),
        const SizedBox(height: 8),
        const _InfoChip(
          icon: Icons.attach_money,
          text: 'Knows what it means to run a business where every dollar counts',
        ),
      ],
    );
  }

  // ──────────────────────────── Email Row ────────────────────────

  Widget _buildEmailRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mail_outline, color: _textGray, size: 20),
        const SizedBox(width: 8),
        SelectableText(
          _contactEmail,
          style: const TextStyle(color: _textGray, fontSize: 15),
        ),
      ],
    );
  }

  // ──────────────────────────── CTA Button ──────────────────────

  Widget _buildLetsTalkButton() {
    return Builder(
      builder: (context) => SizedBox(
        width: 220,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => _launchEmail(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Let's Talk"),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── Actions ─────────────────────────

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: _contactEmail);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }
}

// ───────────────────────────── Helpers ──────────────────────────

/// Small icon + text pair used in the founder card.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: FounderScreen._accentRed, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: FounderScreen._textGray,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
