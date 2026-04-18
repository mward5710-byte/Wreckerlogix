import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Main dashboard — hub for all WreckerLogix modules.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WreckerLogix'),
        actions: [
          Consumer<AuthService>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                return PopupMenuButton<String>(
                  icon: const CircleAvatar(child: Icon(Icons.person)),
                  onSelected: (value) {
                    if (value == 'logout') auth.signOut();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(auth.displayName ?? 'User'),
                    ),
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        auth.role?.toUpperCase() ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => context.push('/login'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            Text('Operations', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _ModuleCard(
                    title: 'Dispatch',
                    subtitle: 'Job management & assignment',
                    icon: Icons.assignment,
                    color: const Color(0xFF1565C0),
                    onTap: () => context.push('/dispatch'),
                  ),
                  _ModuleCard(
                    title: 'GPS Tracking',
                    subtitle: 'Fleet location & routing',
                    icon: Icons.gps_fixed,
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/gps'),
                  ),
                  _ModuleCard(
                    title: 'Voice Commands',
                    subtitle: 'Hands-free operation',
                    icon: Icons.mic,
                    color: const Color(0xFF6A1B9A),
                    onTap: () => context.push('/voice'),
                  ),
                  _ModuleCard(
                    title: 'Photo Docs',
                    subtitle: 'Vehicle documentation',
                    icon: Icons.camera_alt,
                    color: const Color(0xFFE65100),
                    onTap: () => context.push('/photos'),
                  ),
                  _ModuleCard(
                    title: 'Time Tracking',
                    subtitle: 'Shifts & hours',
                    icon: Icons.access_time,
                    color: const Color(0xFF00838F),
                    onTap: () => context.push('/time-tracking'),
                  ),
                  _ModuleCard(
                    title: 'Accounting',
                    subtitle: 'Invoices & payments',
                    icon: Icons.attach_money,
                    color: const Color(0xFF558B2F),
                    onTap: () => context.push('/accounting'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.local_shipping, size: 48,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WreckerLogix',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('AI-Powered Tow Industry Operations',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 3;
    if (width > 600) return 3;
    return 2;
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withAlpha(180)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withAlpha(220), fontSize: 11),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
