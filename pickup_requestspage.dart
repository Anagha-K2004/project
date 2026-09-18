import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequestsPage extends StatelessWidget {
  const PickupRequestsPage({super.key});

  // Update pickup request status
  // Update pickup request status
  Future<void> updateStatus(
      String requestId,
      String userId,
      String historyId,
      String newStatus,
      ) async {
    try {
      // Update admin pickup request
      await FirebaseFirestore.instance
          .collection("pickup_requests")
          .doc(requestId)
          .update({
        "status": newStatus,

        // User notification
        "userNotificationRead": false,
      });

      // Update user's scan history
      if (historyId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("scan_history")
            .doc(historyId)
            .update({
          "status": newStatus,
        });
      }

      print("STATUS UPDATED: $newStatus");
    } catch (e) {
      print("STATUS UPDATE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pickup Requests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pickup_requests")
            .orderBy("timestamp", descending: true)
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
                    Icons.local_shipping,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No Pickup Requests",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "New pickup requests will appear here.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: documents.length,

            itemBuilder: (context, index) {

              final data =
              documents[index].data()
              as Map<String, dynamic>;

              final String wasteType =
                  data["wasteType"] ?? "Unknown Waste";

              final String pickupDate =
                  data["pickupDate"] ?? "Not selected";

              final String pickupTime =
                  data["pickupTime"] ?? "Not selected";

              final String address =
                  data["address"] ?? "Not available";

              final String status =
                  data["status"] ?? "Pending";

              final String userId =
                  data["userId"] ?? "Unknown";

              final String historyId =
                  data["historyId"] ?? "";

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),
                elevation: 3,

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // Waste Type
                      Row(
                        children: [

                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              wasteType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Pickup Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Date: $pickupDate",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Pickup Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Time: $pickupTime",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Address
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const Icon(
                            Icons.location_on,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              "Address: $address",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // User ID
                      Text(
                        "User ID: $userId",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: [
                          "Pending",
                          "Accepted",
                          "Completed",
                        ].contains(status)
                            ? status
                            : "Pending",

                        decoration: const InputDecoration(
                          labelText: "Pickup Status",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.sync,
                            color: Colors.green,
                          ),
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "Pending",
                            child: Text("Pending"),
                          ),

                          DropdownMenuItem(
                            value: "Accepted",
                            child: Text("Accepted"),
                          ),

                          DropdownMenuItem(
                            value: "Completed",
                            child: Text("Completed"),
                          ),
                        ],

                        onChanged: (newStatus) {

                          if (newStatus == null) {
                            return;
                          }

                          updateStatus(
                            documents[index].id,
                            userId,
                            historyId,
                            newStatus,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
