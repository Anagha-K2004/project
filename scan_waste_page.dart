import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pickup_requests/pickup_request_page.dart';

class ScanWastePage extends StatefulWidget {
  const ScanWastePage({super.key});

  @override
  State<ScanWastePage> createState() => _ScanWastePageState();
}

class _ScanWastePageState extends State<ScanWastePage> {
  File? selectedImage;

  String? selectedWasteType;

  final ImagePicker picker = ImagePicker();

  final List<String> wasteTypes = [
    "Organic Waste",
    "Plastic Waste",
    "Paper Waste",
    "Glass Waste",
    "Metal Waste",
  ];

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void requestPickup() {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image"),
        ),
      );
      return;
    }

    if (selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select waste category"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupRequestPage(
          wasteType: selectedWasteType!,
          image: selectedImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Waste"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: selectedImage == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 60,
                      color: Colors.green,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Select Waste Image",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              value: selectedWasteType,
              decoration: const InputDecoration(
                labelText: "Select Waste Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.delete),
              ),
              items: wasteTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWasteType = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: requestPickup,
                icon: const Icon(Icons.local_shipping),
                label: const Text(
                  "Request Waste Pickup",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
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
