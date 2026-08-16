import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:princes/app/router.dart';
import '../../../alarm/data/services/sound_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../data/broadcast_alert_service.dart';

/// Royal Ethereal Settings & Sync Screen crafted with Stitch.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _volumeSlider = 0.8;
  bool _volumeInitialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final soundService = ref.watch(soundServiceProvider);
    final alertsAsync = ref.watch(broadcastAlertsProvider);

    if (!_volumeInitialized) {
      _volumeSlider = soundService.volume;
      _volumeInitialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
            color: Color(0xFFEBDEF4),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFEBDEF4)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF130D1B),
              Color(0xFF1C1328),
              Color(0xFF120B1A),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // ── 1. Premium Royal Profile Card ─────────────────────
            _buildProfileCard(context, authState),

            const SizedBox(height: 20),

            // ── 2. Alarms & Wake-Up Sound Hub ─────────────────────
            _buildSectionHeader('ALARMS & SOUND HUB', Icons.alarm_rounded),
            _buildGlassContainer(
              children: [
                // Ringtone selector
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildIconBadge(
                    Icons.music_note_rounded,
                    const Color(0xFF9D50BB),
                  ),
                  title: const Text(
                    'Alarm & Alert Sound',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    soundService.currentPreset.name,
                    style: const TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          soundService.isPlaying
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_fill_rounded,
                          color: const Color(0xFFEDB1FF),
                          size: 30,
                        ),
                        onPressed: () {
                          if (soundService.isPlaying) {
                            soundService.stop();
                          } else {
                            soundService.playPreview();
                          }
                          setState(() {});
                        },
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9A8C9B),
                      ),
                    ],
                  ),
                  onTap: () => _showSoundPicker(context, soundService),
                ),

                const Divider(color: Color(0x1AFFFFFF), height: 1),

                // Volume slider
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _volumeSlider == 0
                                    ? Icons.volume_off_rounded
                                    : _volumeSlider < 0.5
                                        ? Icons.volume_down_rounded
                                        : Icons.volume_up_rounded,
                                size: 20,
                                color: const Color(0xFFEDB1FF),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Alarm Volume Level',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9D50BB).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEDB1FF).withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              '${(_volumeSlider * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEDB1FF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFFEDB1FF),
                          inactiveTrackColor: const Color(0x33EDB1FF),
                          thumbColor: const Color(0xFFE9C349),
                          overlayColor: const Color(0x29EDB1FF),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _volumeSlider,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          onChanged: (val) {
                            setState(() {
                              _volumeSlider = val;
                            });
                            soundService.setVolume(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0x1AFFFFFF), height: 1),

                // Test Alarm button
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildIconBadge(
                    Icons.fullscreen_rounded,
                    const Color(0xFFE9C349),
                  ),
                  title: const Text(
                    'Wake-Up Screen Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Simulate full-screen morning alarm',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.alarmFullscreen),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Test Alarm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(color: Color(0x1AFFFFFF), height: 1),

                // Battery optimization
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildIconBadge(
                    Icons.battery_charging_full_rounded,
                    const Color(0xFF4CAF50),
                  ),
                  title: const Text(
                    'Battery Exemption Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Ensures reliable ring at 12:00 AM & alarms',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 3. Cloud Sync & Developer Announcements ───────────
            _buildSectionHeader('CLOUD SYNC & NEWS', Icons.cloud_done_rounded),
            _buildGlassContainer(
              children: [
                if (authState.isAuthenticated) ...[
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: _buildIconBadge(
                      Icons.cloud_sync_rounded,
                      const Color(0xFF00B4D8),
                    ),
                    title: const Text(
                      'Instant Supabase Sync',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Push local changes to private cloud partition',
                      style: TextStyle(
                        color: Color(0xFFD1C2D2),
                        fontSize: 13,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final ds = ref.read(taskDatasourceProvider);
                        await ds.syncFromCloud();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF9D50BB),
                              content: Text('Synced snapshot with Supabase!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF241C2C),
                        foregroundColor: const Color(0xFFEDB1FF),
                        side: const BorderSide(color: Color(0x33EDB1FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Sync Now'),
                    ),
                  ),
                  const Divider(color: Color(0x1AFFFFFF), height: 1),
                ],

                // Broadcast Announcements
                alertsAsync.when(
                  data: (alerts) {
                    if (alerts.isEmpty) {
                      return const ListTile(
                        leading: Icon(
                          Icons.campaign_outlined,
                          color: Color(0xFFD1C2D2),
                        ),
                        title: Text(
                          'Developer Announcements',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'No new release announcements at this moment',
                          style: TextStyle(color: Color(0xFF9A8C9B)),
                        ),
                      );
                    }
                    return Column(
                      children: alerts.map((alert) {
                        return ListTile(
                          leading: _buildIconBadge(
                            Icons.notifications_active_rounded,
                            const Color(0xFFE9C349),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE9C349).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  alert.tag.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFE9C349),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              alert.message,
                              style: const TextStyle(
                                color: Color(0xFFD1C2D2),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFEDB1FF),
                      ),
                    ),
                  ),
                  error: (_, __) => const ListTile(
                    leading: Icon(
                      Icons.campaign_outlined,
                      color: Color(0xFF9A8C9B),
                    ),
                    title: Text(
                      'Announcements',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Up to date',
                      style: TextStyle(color: Color(0xFF9A8C9B)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 4. Photo Memories & Cache Vault ───────────────────
            _buildSectionHeader('PHOTO MEMORIES VAULT', Icons.photo_library_rounded),
            _buildGlassContainer(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildIconBadge(
                    Icons.photo_album_rounded,
                    const Color(0xFFE6BEB2),
                  ),
                  title: const Text(
                    'Memory Background Pool',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Rotating photos for wake-up screen backgrounds',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9A8C9B),
                  ),
                  onTap: () => context.push(AppRoutes.photoPicker),
                ),
                const Divider(color: Color(0x1AFFFFFF), height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photo Cache Storage',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '0 MB / 150 MB',
                            style: TextStyle(
                              color: Color(0xFFD1C2D2),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.05,
                          minHeight: 6,
                          backgroundColor: Color(0x33FFFFFF),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFE6BEB2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 5. Data Management / Reset Zone ───────────────────
            _buildSectionHeader('DANGER ZONE', Icons.warning_amber_rounded),
            _buildGlassContainer(
              borderColor: const Color(0x44FF5252),
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildIconBadge(
                    Icons.delete_sweep_rounded,
                    const Color(0xFFFF5252),
                  ),
                  title: const Text(
                    'Reset All Tasks & Routines',
                    style: TextStyle(
                      color: Color(0xFFFF8A80),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Wipes tasks for a fresh restart (cannot be undone)',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 13,
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _confirmResetAll(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5252),
                      side: const BorderSide(color: Color(0x66FF5252)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Footer ────────────────────────────────────────────
            Center(
              child: Text(
                'Princess Companion • Version 1.0.0 (Royal Ethereal Edition)',
                style: TextStyle(
                  color: const Color(0xFF9A8C9B).withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Profile Card Builder ─────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context, AuthStateModel authState) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x3D9D50BB),
            Color(0x1F6E48AA),
            Color(0x2B241C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x3DEDB1FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D50BB).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with glowing ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE9C349), Color(0xFFEDB1FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE9C349).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF241C2C),
                  child: Text(
                    authState.displayName.isNotEmpty
                        ? authState.displayName[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      color: Color(0xFFE9C349),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      authState.isAuthenticated
                          ? (authState.email ?? '')
                          : 'Guest Explorer (Offline)',
                      style: const TextStyle(
                        color: Color(0xFFD1C2D2),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Live Sync status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: authState.isAuthenticated
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: authState.isAuthenticated
                              ? Colors.green.withOpacity(0.4)
                              : Colors.orange.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: authState.isAuthenticated
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            authState.isAuthenticated
                                ? 'Supabase Sync Active'
                                : 'Local Storage Only',
                            style: TextStyle(
                              color: authState.isAuthenticated
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.login),
                  icon: Icon(
                    authState.isAuthenticated
                        ? Icons.manage_accounts_rounded
                        : Icons.login_rounded,
                    size: 18,
                  ),
                  label: Text(
                    authState.isAuthenticated
                        ? 'Manage Profile'
                        : 'Sign In / Connect',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEDB1FF),
                    side: const BorderSide(color: Color(0x66EDB1FF)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFEDB1FF)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEDB1FF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1F241C2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? const Color(0x24FFFFFF),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _confirmResetAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF241C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reset All Tasks?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will delete all current tasks so you can start completely fresh. This cannot be undone.',
          style: TextStyle(color: Color(0xFFD1C2D2)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFD1C2D2))),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ds = ref.read(taskDatasourceProvider);
      await ds.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF9D50BB),
            content: Text('All tasks cleared. Fresh start ready!'),
          ),
        );
      }
    }
  }

  void _showSoundPicker(BuildContext context, SoundService soundService) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1328),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Alarm Sound',
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () {
                              soundService.stop();
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0x22FFFFFF)),
                    ...SoundService.presets.map((preset) {
                      final isSelected =
                          soundService.selectedSoundId == preset.id;
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? const Color(0xFFEDB1FF)
                              : Colors.grey,
                        ),
                        title: Text(
                          preset.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          preset.description,
                          style: const TextStyle(
                            color: Color(0xFFD1C2D2),
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          color: const Color(0xFFE9C349),
                          iconSize: 32,
                          onPressed: () {
                            soundService.playPreview(preset);
                          },
                        ),
                        onTap: () async {
                          await soundService.setSelectedSound(preset.id);
                          soundService.playPreview(preset);
                          setSheetState(() {});
                          setState(() {});
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      soundService.stop();
    });
  }
}
