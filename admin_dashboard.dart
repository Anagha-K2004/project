import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pickup_requests_page.dart';
import 'users_page.dart';
import 'admin_notifications_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",

            onPressed: () async {

              // Show confirmation dialog
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                      "Are you sure you want to logout?",
                    ),
                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {

                // Firebase logout
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                // Go back to admin login
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Welcome Admin 👋",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // TOTAL USERS
            // =========================

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),

              builder: (context, snapshot) {

                int totalUsers = 0;

                if (snapshot.hasData) {
                  totalUsers = snapshot.data!.docs.length;
                }

                return statCard(
                  icon: Icons.people,
                  title: "Total Users",
                  count: totalUsers.toString(),
                );
              },
            ),

            const SizedBox(height: 15),

            // =========================
            // TOTAL PICKUP REQUESTS
            // =========================

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pickup_requests")
                  .snapshots(),

              builder: (context, snapshot) {

                int totalRequests = 0;

                if (snapshot.hasData) {
                  totalRequests =
                      snapshot.data!.docs.length;
                }

                return statCard(
                  icon: Icons.local_shipping,
                  title: "Total Pickup Requests",
                  count: totalRequests.toString(),
                );
              },
            ),

            const SizedBox(height: 15),

            // =========================
            // PENDING REQUESTS
            // =========================

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pickup_requests")
                  .where(
                "status",
                isEqualTo: "Pending",
              )
                  .snapshots(),

              builder: (context, snapshot) {

                int pendingRequests = 0;

                if (snapshot.hasData) {
                  pendingRequests =
                      snapshot.data!.docs.length;
                }

                return statCard(
                  icon: Icons.pending_actions,
                  title: "Pending Requests",
                  count: pendingRequests.toString(),
                );
              },
            ),

            const SizedBox(height: 15),

            // =========================
            // COMPLETED REQUESTS
            // =========================

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pickup_requests")
                  .where(
                "status",
                isEqualTo: "Completed",
              )
                  .snapshots(),

              builder: (context, snapshot) {

                int completedRequests = 0;

                if (snapshot.hasData) {
                  completedRequests =
                      snapshot.data!.docs.length;
                }

                return statCard(
                  icon: Icons.check_circle,
                  title: "Completed Requests",
                  count: completedRequests.toString(),
                );
              },
            ),

            const SizedBox(height: 30),

            // =========================
            // PICKUP REQUESTS
            // =========================

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.local_shipping,
                  color: Colors.green,
                  size: 35,
                ),

                title: const Text(
                  "Pickup Requests",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "View and manage waste pickup requests",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const PickupRequestsPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // USERS
            // =========================

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Colors.green,
                  size: 35,
                ),

                title: const Text(
                  "Users",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "View registered users",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const UsersPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // NOTIFICATIONS
            // =========================

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Colors.green,
                  size: 35,
                ),

                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "View new pickup request notifications",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const AdminNotificationsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // STAT CARD
  // =========================

  Widget statCard({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green,

              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
