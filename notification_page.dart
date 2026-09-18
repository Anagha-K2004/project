import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Mark notification as read
  Future<void> markAsRead(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection("pickup_requests")
          .doc(requestId)
          .update({
        "userNotificationRead": true,
      });
    } catch (e) {
      print("NOTIFICATION READ ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login again"),
        ),
      );
    }

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
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pickup_requests")
            .where("userId", isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
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
                    "No notifications",
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

          // Only show NEW / UNREAD status notifications
          final notifications =
          snapshot.data!.docs.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            final status = data["status"] ?? "";

            final bool notificationRead =
                data["userNotificationRead"] ?? true;

            // Pending is not a notification
            // Read notifications are not shown
            return status != "Pending" &&
                notificationRead == false;
          }).toList();

          if (notifications.isEmpty) {
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
            itemCount: notifications.length,

            itemBuilder: (context, index) {
              final doc = notifications[index];

              final data =
              doc.data() as Map<String, dynamic>;

              final wasteType =
                  data["wasteType"] ?? "Waste";

              final status =
                  data["status"] ?? "Unknown";

              IconData notificationIcon;
              Color iconColor;
              String message;
              String title;

              if (status == "Accepted") {
                notificationIcon =
                    Icons.check_circle;
                iconColor = Colors.blue;

                title = "Pickup Request Accepted";

                message =
                "Your pickup request has been accepted.";
              } else if (status == "Completed") {
                notificationIcon = Icons.task_alt;
                iconColor = Colors.green;

                title = "Pickup Completed";

                message =
                "Your waste pickup has been completed.";
              } else {
                notificationIcon = Icons.info;
                iconColor = Colors.orange;

                title = "Pickup Status Updated";

                message =
                "Your pickup request status has been updated.";
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor,
                    child: Icon(
                      notificationIcon,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(message),

                      const SizedBox(height: 4),

                      Text(
                        "Waste: $wasteType",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Tap notification → mark as read
                  onTap: () async {
                    await markAsRead(doc.id);
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
