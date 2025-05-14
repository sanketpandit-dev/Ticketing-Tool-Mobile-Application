import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/Dash_ticket_list.dart';
import 'package:tickteting_tool/Controller/Login_Controller.dart';
import 'package:tickteting_tool/Controller/TicketCountController.dart';
import 'package:tickteting_tool/Screens/Tickets/RaiseTickets.dart';
import 'package:tickteting_tool/Screens/Tickets/ViewTickets.dart';
import 'package:tickteting_tool/Screens/User%20Dashboard/Dash_ticket_list.dart';
import 'package:tickteting_tool/Screens/User%20Dashboard/ResolvedTicketsCheck.dart';
import 'package:tickteting_tool/Screens/User%20Dashboard/appdrawer.dart';
import 'package:tickteting_tool/Screens/login/LoginScreen.dart';


class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> statusList = const [
    {
      'title': 'Total Tickets',
      'color': Colors.lightBlue,
      'icon': Icons.pending_actions
    },
    {
      'title': 'Pending',
      'color': Colors.orange,
      'icon': Icons.mark_email_unread
    },
    {
      'title': 'Confirmed',
      'color': Colors.green,
      'icon': Icons.outgoing_mail
    },
    {
      'title': 'Discard',
      'color': Colors.redAccent,
      'icon': Icons.delete_outline
    },
  ];

  final Map<String, dynamic> confirmedCard = const {
    'title': 'Resolved',
    'color': Colors.green,
    'icon': Icons.check_circle,
    'description': 'View and Confirm your Ticket or Reopen'
  };



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketCountController>(context, listen: false).loadCounts();
    });
  }

  void _navigateToTicketList(String statusType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => TicketListController(),
          child: DashTicketListScreen(statusType: statusType),
        ),
      ),
    );
  }

  // New method to handle logout
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF3B82F6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              Provider.of<TicketCountController>(context, listen: false).loadCounts();
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
                onTap: () {
                  // Call logout handler
                  _handleLogout();
                },
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(username: widget.username),
      backgroundColor: Colors.grey[100],
      body: Consumer<TicketCountController>(
        builder: (context, countController, child) {
          if (countController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (countController.error.isNotEmpty) {
            return Center(child: Text(countController.error, style: TextStyle(color: Colors.red)));
          }
          final List<int> counts = [
            countController.totalCount,
            countController.pendingCount,
            countController.completeCount,
            countController.discardCount,
            countController.confirmedCount,

          ];




          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 5),
                    Text(
                      'Ticket Management Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: 40),

              // Wide Confirmed Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Resolvedticketscheck()));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 135,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Card container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 45, 20, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      confirmedCard['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 3,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: (confirmedCard['color'] as Color).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  confirmedCard['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Circle icon
                        Positioned(
                          top: -25,
                          left: 20,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: (confirmedCard['color'] as Color).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: (confirmedCard['color'] as Color).withOpacity(0.15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(confirmedCard['icon'], color: confirmedCard['color'], size: 22),
                                    const SizedBox(height: 4),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Status count cards
              SizedBox(height: 5),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth;
                    final double padding = 15.0;
                    final double spacing = 15.0;
                    final int crossAxisCount = 2;
                    final double cardWidth = (maxWidth - (padding * 2) - spacing) / crossAxisCount;
                    final double cardHeight = cardWidth * 0.9;
                    final double circleTop = -25.0;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 35, bottom: 20),
                        itemCount: statusList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: 40,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemBuilder: (context, index) {
                          final item = statusList[index];
                          return GestureDetector(
                            onTap: () {
                              _navigateToTicketList(item['title']);
                            },
                            child: Container(
                              width: cardWidth,
                              height: cardHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Card container - fixed size for all cards
                                  Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 45.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item['title'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            height: 3,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: (item['color'] as Color).withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: circleTop,
                                    left: 0,
                                    right: 0,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (item['color'] as Color).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: (item['color'] as Color).withOpacity(0.15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(item['icon'], color: item['color'], size: 22),
                                                const SizedBox(height: 4),
                                                Text(
                                                  counts[index].toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: item['color'],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}