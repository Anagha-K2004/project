import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'history_page.dart';
import '../pickup_requests/pickup_request_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({
    super.key,
    required this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = "";
  String email = "";
  String phone = "";

  // PICK IMAGE FROM CAMERA OR GALLERY
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image selection failed: $e"),
        ),
      );
    }
  }

  // SHOW WASTE RESULT
  Future<void> showWasteResult() async {
    final String? wasteType = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Waste Type",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ORGANIC
                  ListTile(
                    leading: const Icon(
                      Icons.eco,
                      color: Colors.green,
                    ),
                    title: const Text("Organic Waste"),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        "Organic Waste",
                      );
                    },
                  ),

                  // PLASTIC
                  ListTile(
                    leading: const Icon(
                      Icons.local_drink,
                      color: Colors.blue,
                    ),
                    title: const Text("Plastic Waste"),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        "Plastic Waste",
                      );
                    },
                  ),

                  // PAPER
                  ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.orange,
                    ),
                    title: const Text("Paper Waste"),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        "Paper Waste",
                      );
                    },
                  ),

                  // GLASS
                  ListTile(
                    leading: const Icon(
                      Icons.wine_bar,
                      color: Colors.purple,
                    ),
                    title: const Text("Glass Waste"),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        "Glass Waste",
                      );
                    },
                  ),

                  // METAL
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Colors.grey,
                    ),
                    title: const Text("Metal Waste"),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        "Metal Waste",
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // After selecting waste type
    if (!mounted || wasteType == null) {
      return;
    }

    showResult(wasteType);
  }

  // SHOW RESULT
  void showResult(String wasteType) {
    String binType;

    if (wasteType == "Organic Waste") {
      binType = "Green Bin";
    } else if (wasteType == "Plastic Waste") {
      binType = "Blue Bin";
    } else if (wasteType == "Paper Waste") {
      binType = "Blue Bin";
    } else if (wasteType == "Glass Waste") {
      binType = "Green Bin";
    } else {
      binType = "Metal Recycling Bin";
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Waste Result",
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 250,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected Image
                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        height: 120,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 15),

                  Text(
                    wasteType,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Recommended: $binType",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PickupRequestPage(
                              wasteType: wasteType,
                              image: selectedImage,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "REQUEST WASTE PICKUP",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // SAVE SCAN HISTORY

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // GET USER DETAILS FROM FIRESTORE
  Future<void> loadUserData() async {
    User? user = auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      DocumentSnapshot userData =
      await firestore.collection("users").doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          name = userData["name"] ?? widget.userName;
          email = userData["email"] ?? user.email ?? "";
          phone = userData["phone"] ?? "";
        });
      }
    } catch (e) {
      setState(() {
        name = widget.userName;
        email = user.email ?? "";
      });
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      homeScreen(),
      scanScreen(),
      historyScreen(),
      const NotificationPage(),
      profileScreen(),
    ];

    return Scaffold(
      body: pages[selectedIndex],

      // =====================================================
      // BOTTOM NAVIGATION BAR
      // =====================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        // IMPORTANT:
        // Do NOT use "const" here because StreamBuilder is used.
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: "Scan",
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: "History",
          ),

          // =================================================
          // NOTIFICATION ICON + RED DOT
          // =================================================

          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pickup_requests")
                  .where(
                "userId",
                isEqualTo:
                FirebaseAuth.instance.currentUser?.uid,
              )
                  .snapshots(),

              builder: (context, snapshot) {
                bool hasNotification = false;

                if (snapshot.hasData) {
                  hasNotification = snapshot.data!.docs.any((doc) {
                    final data =
                    doc.data() as Map<String, dynamic>;

                    return data["status"] != "Pending" &&
                        data["userNotificationRead"] == false;
                  });
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications,
                    ),

                    // RED DOT
                    if (hasNotification)
                      Positioned(
                        right: -2,
                        top: -2,
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
            label: "Notifications",
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HOME SCREEN
  // =========================================================

  Widget homeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Waste Segregation Assistant",
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Welcome ${name.isEmpty ? widget.userName : name} 👋",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Waste Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                categoryCard(
                  Icons.recycling,
                  "Plastic",
                ),

                categoryCard(
                  Icons.description,
                  "Paper",
                ),

                categoryCard(
                  Icons.delete,
                  "Organic",
                ),
              ],
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                ),

                title: const Text(
                  "Scan Waste",
                ),

                subtitle: const Text(
                  "Upload image and identify waste",
                ),

                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_shipping,
                  color: Colors.green,
                ),

                title: const Text(
                  "Request Waste Pickup",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "Schedule a waste pickup",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const PickupRequestPage(
                        wasteType: "General Waste",
                      ),
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

  // =========================================================
  // CATEGORY CARD
  // =========================================================

  Widget categoryCard(
      IconData icon,
      String title,
      ) {
    return GestureDetector(
      onTap: () {
        showResult("$title Waste");
      },

      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green,

            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(title),
        ],
      ),
    );
  }

  // =========================================================
  // SCAN SCREEN
  // =========================================================

  Widget scanScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Waste",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 30),

              // Scan Icon
              const Icon(
                Icons.recycling,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 15),

              const Text(
                "Identify Your Waste",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Take a photo or choose an image\n"
                    "to identify the type of waste.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // Camera Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.camera);
                  },

                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Take Photo",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Gallery Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },

                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.green,
                  ),

                  label: const Text(
                    "Choose from Gallery",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.green,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.green,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Selected Image
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),

                  child: Image.file(
                    selectedImage!,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              if (selectedImage != null) ...[
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      showWasteResult();
                    },

                    icon: const Icon(
                      Icons.search,
                    ),

                    label: const Text(
                      "IDENTIFY WASTE",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HISTORY SCREEN
  // =========================================================

  Widget historyScreen() {
    return const HistoryPage();
  }

  // =========================================================
  // PROFILE SCREEN
  // =========================================================

  Widget profileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5EE),

      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F9D58),
              Color(0xFF6BCB8B),
              Color(0xFFEAF5EE),
            ],
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 110),

              // ================= PROFILE GLASS HEADER =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // ================= PROFILE IMAGE =================
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.35),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: const CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person,
                          size: 65,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= USER NAME =================
                    Text(
                      name.isEmpty ? "User" : name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // ================= SUBTITLE =================
                    Text(
                      "Waste Segregation Assistant",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ================= PERSONAL INFORMATION =================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    const Row(
                      children: [
                        Icon(
                          Icons.person_pin,
                          color: Colors.green,
                          size: 25,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Name
                    profileInfoCard(
                      icon: Icons.person_outline,
                      title: "Name",
                      value: name.isEmpty ? "Not available" : name,
                    ),

                    // Email
                    profileInfoCard(
                      icon: Icons.email_outlined,
                      title: "Email",
                      value: email.isEmpty ? "Not available" : email,
                    ),

                    // Phone
                    profileInfoCard(
                      icon: Icons.phone_outlined,
                      title: "Phone",
                      value: phone.isEmpty ? "Not available" : phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= GLASS LOGOUT BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton.icon(
                    onPressed: logout,

                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 22,
                    ),

                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.85),
                      foregroundColor: Colors.white,
                      elevation: 8,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROFILE INFORMATION CARD
  // =========================================================

  Widget profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // ICON
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.green,
              size: 25,
            ),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? "Not available" : value,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
