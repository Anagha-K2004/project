import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registered Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
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
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.people,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No Users Found",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Registered users will appear here.",
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

              final String name =
                  data["name"] ?? "Unknown User";

              final String email =
                  data["email"] ?? "No email";

              final String phone =
                  data["phone"] ?? "No phone";

              final String role =
                  data["role"] ?? "user";

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

                      // User name
                      Row(
                        children: [

                          const CircleAvatar(
                            radius: 25,
                            backgroundColor:
                            Colors.green,

                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Email
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const Icon(
                            Icons.email,
                            size: 20,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Email: $email",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Phone
                      Row(
                        children: [

                          const Icon(
                            Icons.phone,
                            size: 20,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "Phone: $phone",
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Role
                      Row(
                        children: [

                          const Icon(
                            Icons.admin_panel_settings,
                            size: 20,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "Role: $role",
                          ),
                        ],
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
