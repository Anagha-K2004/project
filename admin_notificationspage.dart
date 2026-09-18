import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pickup_requests_page.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  // Mark notification as read
  Future<void> markAsRead(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection("pickup_requests")
          .doc(requestId)
          .update({
        "adminNotificationRead": true,
      });

      print("ADMIN NOTIFICATION READ");
    } catch (e) {
      print("ADMIN NOTIFICATION READ ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pickup_requests")
            .where("status", isEqualTo: "Pending")
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No new pickup requests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show only unread admin notifications
          final requests = snapshot.data!.docs.where((doc) {
            final request =
            doc.data() as Map<String, dynamic>;

            return request["adminNotificationRead"] == false;
          }).toList();

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No new notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: requests.length,

            itemBuilder: (context, index) {
              final doc = requests[index];

              final request =
              doc.data() as Map<String, dynamic>;

              final wasteType =
                  request["wasteType"] ?? "Waste";

              final address =
                  request["address"] ??
                      "Address not available";

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),

                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                  ),

                  title: const Text(
                    "New pickup request received",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Waste: $wasteType",
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        "Status: Pending",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Address: $address",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () async {
                    // Mark this notification as read
                    await markAsRead(doc.id);

                    // Open pickup requests page
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const PickupRequestsPage(),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
