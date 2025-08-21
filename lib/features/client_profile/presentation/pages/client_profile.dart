import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/model/client_profile_model.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../client_login_manager/client_login_manager.dart';


class ClientProfileScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ClientProfileScreen({super.key, required this.clientProfileModel});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoggingOut = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);

    bool isCleared = await ClientLoginManager().clearClientProfile();
    if (!mounted) return;

    setState(() => _isLoggingOut = false);

    if (isCleared) {
      context.go(AppRoutes.signInOptions);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to logout. Please try again.")),
      );
    }
  }

  Future<void> _onRefresh() async {
    // Simulate refresh delay, replace with real reload if needed
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile refreshed")),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value=="NA" ? "add mobile number" : value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: Colors.grey.shade400, size: 20), // hint editable
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.clientProfileModel;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight: 300,
              backgroundColor: Colors.blueAccent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                  final t = ((constraints.maxHeight - collapsedHeight) / (300 - collapsedHeight))
                      .clamp(0.0, 1.0);
                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 12, bottom: 12),
                    title: Row(
                      children: [
                        // Avatar with scale and fade
                        Transform.scale(
                          scale: 1 - 0.3 * t, // scale down 30% when expanded
                          child: Opacity(
                            opacity: 1 - t,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(profile.profileImage),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name slides and fades
                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1 - t,
                            child: Opacity(
                              opacity: 1 - t,
                              child: Text(
                                profile.profileName,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Center(
                          child: Opacity(
                            opacity: t,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: "client-image",
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundImage: NetworkImage(profile.profileImage),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  profile.profileName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Phone No", profile.phoneNo, Icons.phone),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Email", profile.email, Icons.email),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Age", profile.age, Icons.cake),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Gender", profile.gender, Icons.wc),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Height", "${profile.height} cm", Icons.height),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Weight", "${profile.weight} kg", Icons.monitor_weight),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Region", profile.region, Icons.location_city),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Location", profile.location, Icons.place),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Dietitian ID", profile.dieticianId, Icons.person),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Profile ID", profile.profileId, Icons.account_box),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width ,
                          child: _buildInfoCard("Date Time", profile.dttm, Icons.calendar_today),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _isLoggingOut ? null : _logout,
                      icon: _isLoggingOut
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.logout, color: Colors.white,),
                      label: Text(
                        _isLoggingOut ? "Logging out..." : "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
