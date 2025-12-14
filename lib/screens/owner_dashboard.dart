import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestify/services/auth_service.dart';
import 'package:nestify/screens/owner_complaint_list_screen.dart';
import 'package:nestify/screens/owner_students_list_screen.dart';
import 'package:nestify/screens/owner_settings_screen.dart';
import 'package:nestify/screens/owner_dinner_voting_setup_screen.dart';
import 'package:nestify/screens/owner_payment_dashboard_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  static const routeName = '/owner/dashboard';

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _OwnerHomePage(),
    const OwnerComplaintListScreen(),
    const DinnerVotingSetupScreen(),
    const OwnerStudentsListScreen(),
    const OwnerPaymentDashboardScreen(),
  ];

  /// Handle logout with confirmation and proper cleanup
  /// This clears the Firebase Auth session and resets persistent login
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logging out...')),
        );
      }

      // Sign out from Firebase - this clears the persistent session
      await AuthService().signOut();
      
      // AuthWrapper's StreamBuilder will automatically detect the sign out
      // and redirect to WelcomeScreen - no manual navigation needed!
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 28, child: Icon(Icons.business)),
                    SizedBox(height: 8),
                    Text('Owner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerSettingsScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.report_problem), label: 'Complaints'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Voting'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Payments'),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Owner Dashboard';
      case 1:
        return 'Complaints';
      case 2:
        return 'Dinner Voting';
      case 3:
        return 'Students';
      case 4:
        return 'Payments';
      default:
        return 'Owner Dashboard';
    }
  }
}

// Home Page with Statistics
class _OwnerHomePage extends StatelessWidget {
  const _OwnerHomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // Statistics Section
          Text(
            'Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Cards
          if (userId != null) ...[
            // Total Students Card
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error loading students count: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _StatisticCard(
                    icon: Icons.group,
                    title: 'Total Students',
                    value: '...',
                    color: Colors.blue,
                    onTap: () {},
                  );
                }
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                print('Students count: $count');
                return _StatisticCard(
                  icon: Icons.group,
                  title: 'Total Students',
                  value: count.toString(),
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerStudentsListScreen()),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Pending Complaints Card
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error loading complaints: ${snapshot.error}');
                }
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _StatisticCard(
                  icon: Icons.report_problem,
                  title: 'Pending Complaints',
                  value: count.toString(),
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerComplaintListScreen()),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Dinner Voting Card
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dinner_votes')
                  .where('date', isGreaterThanOrEqualTo: _getTodayTimestamp())
                  .where('date', isLessThan: _getTomorrowTimestamp())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error loading dinner votes: ${snapshot.error}');
                }
                
                final isActive = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                int totalVotes = 0;
                String dishName = '';
                
                if (isActive) {
                  try {
                    final doc = snapshot.data!.docs.first;
                    final yesCount = doc.data().toString().contains('yesCount') ? doc.get('yesCount') ?? 0 : 0;
                    final noCount = doc.data().toString().contains('noCount') ? doc.get('noCount') ?? 0 : 0;
                    totalVotes = yesCount + noCount;
                    dishName = doc.data().toString().contains('dishName') ? doc.get('dishName') ?? '' : '';
                  } catch (e) {
                    print('Error parsing dinner vote data: $e');
                  }
                }
                
                return _StatisticCard(
                  icon: Icons.restaurant_menu,
                  title: 'Today\'s Voting',
                  value: isActive 
                      ? '$totalVotes votes${dishName.isNotEmpty ? '\n$dishName' : ''}' 
                      : 'Not active',
                  color: Colors.deepOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DinnerVotingSetupScreen()),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Timestamp _getTodayTimestamp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return Timestamp.fromDate(today);
  }

  Timestamp _getTomorrowTimestamp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return Timestamp.fromDate(tomorrow);
  }
}

// Statistic Card Widget
class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
