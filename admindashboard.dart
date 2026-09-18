import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pickup_requests_page.dart';
import 'users_page.dart';
import 'admin_notifications_page.dart';
import 'admin_login_page.dart';

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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("pickup_requests")
                .where("status", isEqualTo: "Pending")
                .snapshots(),
            builder: (context, snapshot) {
              bool hasNewNotification = false;

              if (snapshot.hasData) {
                hasNewNotification = snapshot.data!.docs.any((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return data["adminNotificationRead"] == false;
                });
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const AdminNotificationsPage(),
                        ),
                      );
                    },
                  ),

                  if (hasNewNotification)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.logout,
            ),

            onPressed: () {
              showDialog(
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
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          Navigator.pop(context);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const AdminLoginPage(),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
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
