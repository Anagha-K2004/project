import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  bool hidePassword = true;

  bool isLoading = false;

  Future<void> adminLogin() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // Firebase Authentication login
      UserCredential userCredential =
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // Get user details from Firestore
      DocumentSnapshot userDocument =
      await firestore
          .collection("users")
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {

        await auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Admin details not found in Firestore",
            ),
          ),
        );

        return;
      }

      Map<String, dynamic> data =
      userDocument.data() as Map<String, dynamic>;

      String role = data["role"] ?? "";

      // Check admin role
      if (role == "admin") {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin Login Successful"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const AdminDashboard(),
          ),
        );

      } else {

        await auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You are not authorized as Admin",
            ),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {

      String message = "Login failed";

      if (e.code == "user-not-found") {
        message = "Admin account not found";
      } else if (e.code == "wrong-password") {
        message = "Incorrect password";
      } else if (e.code == "invalid-credential") {
        message = "Invalid email or password";
      } else if (e.code == "invalid-email") {
        message = "Invalid email address";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "Admin Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,

              decoration: const InputDecoration(
                labelText: "Admin Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,

              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),

                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : adminLogin,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
