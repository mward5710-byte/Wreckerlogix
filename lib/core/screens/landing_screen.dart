import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Marketing landing page showcasing WreckerLogix value propositions
/// for both drivers and fleet owners.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // ── Brand Colors ──────────────────────────────────────────────────
  static const Color _bgDark = Color(0xFF1A1A2E);
  static const Color _cardDark = Color(0xFF232340);
  static const Color _accentRed = Color(0xFFD63031);
  static const Color _accentGreen = Color(0xFF27AE60);
  static const Color _accentBlue = Color(0xFF2980B9);
  static const Color _textWhite = Color(0xFFFFFFFF);
  static const Color _textGrey = Color(0xFFB0B0B0);
  static const Color _quoteBorder = Color(0xFF3A3A5C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            child: Column(
              children: [
                if (isWide)
                  _buildWideLayout(context)
                else
                  _buildNarrowLayout(context),
                const SizedBox(height: 48),
                _buildCtaBanner(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Wide (Desktop) layout: side-by-side columns ───────────────────
  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDriverSection(context)),
          const SizedBox(width: 48),
          Expanded(child: _buildFleetOwnerSection(context)),
        ],
      ),
    );
  }

  // ── Narrow (Mobile) layout: stacked vertically ────────────────────
  Widget _buildNarrowLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDriverSection(context),
          const SizedBox(height: 48),
          _buildFleetOwnerSection(context),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION: FOR THE DRIVER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildDriverSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.person_outline, 'FOR THE DRIVER'),
        const SizedBox(height: 16),
        const Text(
          'AI Voice Copilot on Your Phone',
          style: TextStyle(
            color: _textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        _buildQuoteBubble(),
        const SizedBox(height: 28),
        _buildFeatureRow(
          Icons.mic,
          'Hands-Free Voice Interface',
          'FMCSA-compliant, no screen touching required',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.trending_up,
          'AI Route Optimization',
          'Saves ~\$180/mo per truck in fuel costs',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.access_time,
          'Smart HOS Tracking',
          'Predictive alerts before violations happen',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.assignment_outlined,
          'Digital DVIR',
          'Voice-guided inspections in 3 min vs 15',
        ),
      ],
    );
  }

  Widget _buildQuoteBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.mic, color: _accentRed, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: _quoteBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '"Good morning Carlos, you\'ve got a load to Memphis today. '
              'I-65 South is clear, your HOS resets at 2pm, and there\'s '
              'a fuel stop in 47 miles saving you \$0.18/gal."',
              style: TextStyle(
                color: _textGrey,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION: FOR THE FLEET OWNER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFleetOwnerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.dashboard_outlined, 'FOR THE FLEET OWNER'),
        const SizedBox(height: 16),
        const Text(
          'Complete Command Center',
          style: TextStyle(
            color: _textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        _buildStatsDashboard(),
        const SizedBox(height: 28),
        _buildFeatureRow(
          Icons.public,
          'Real-Time Fleet Dashboard',
          'Every truck, live, color-coded by status',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.verified_outlined,
          'Compliance Scorecards',
          'CSA scores, audit-ready reports at a glance',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.bar_chart,
          'Driver Performance Analytics',
          'Fuel efficiency, on-time rates, safety metrics',
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.attach_money,
          'Financial Tracking',
          'Per-truck P&L and revenue visibility',
        ),
      ],
    );
  }

  Widget _buildStatsDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('24', 'ACTIVE TRUCKS', _accentRed),
              ),
              Expanded(
                child: _buildStatItem('98%', 'COMPLIANCE', _accentGreen),
              ),
              Expanded(
                child: _buildStatItem('94%', 'ON-TIME', _accentBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildProgressBar(_accentRed),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: _buildProgressBar(_accentGreen),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: _buildProgressBar(_accentBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: _textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED COMPONENTS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: _accentRed, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: _accentRed,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: _accentRed.withAlpha(80),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: _accentRed, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CTA BANNER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCtaBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: _accentRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'One Platform. No Hardware. Deploy in Under 1 Hour.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Works on any smartphone — just download and go',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFCCCC),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _textWhite,
                foregroundColor: _accentRed,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => context.go('/'),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
