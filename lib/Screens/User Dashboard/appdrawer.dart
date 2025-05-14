import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/Login_Controller.dart';
import 'package:tickteting_tool/Screens/Tickets/RaiseTickets.dart';
import 'package:tickteting_tool/Screens/Tickets/ViewTickets.dart';
import 'package:tickteting_tool/Screens/User%20Dashboard/UserDashboard.dart';
import 'package:tickteting_tool/Screens/login/LoginScreen.dart';

class AppDrawer extends StatefulWidget {
  final String username;

  const AppDrawer({super.key, required this.username});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isDashboardExpanded = false;
  bool _isTicketsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 20,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20),
              color: Color(0xFF3B82F6),
              width: double.infinity,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.username.isNotEmpty ? widget.username : 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Drawer items
            const SizedBox(height: 10),
            // Dashboard item with expandable options
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
              title: const Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                _isDashboardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _isDashboardExpanded = !_isDashboardExpanded;
                  if (_isDashboardExpanded) {
                    _isTicketsExpanded = false;
                  }
                });
              },
            ),
            if (_isDashboardExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: ListTile(
                  leading: const Icon(Icons.visibility, color: Colors.grey),
                  title: const Text('View Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to dashboard
                  },
                ),
              ),
            // Tickets item with expandable options
            ListTile(
              leading: const Icon(Icons.confirmation_number, color: Color(0xFF3B82F6)),
              title: const Text(
                'Tickets',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                _isTicketsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _isTicketsExpanded = !_isTicketsExpanded;
                  if (_isTicketsExpanded) {
                    _isDashboardExpanded = false;
                  }
                });
              },
            ),
            if (_isTicketsExpanded)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: Colors.grey),
                      title: const Text('Raise Ticket'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RaiseTickets()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigating to Raise Ticket'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: ListTile(
                      leading: const Icon(Icons.list_alt, color: Colors.grey),
                      title: const Text('View Tickets'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TicketListScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigating to View Tickets'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.grey),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                _handleLogout();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

  }
  Future<void> _handleLogout() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();
    // Navigate to LoginScreen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}