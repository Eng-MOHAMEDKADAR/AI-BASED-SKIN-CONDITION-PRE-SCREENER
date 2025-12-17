import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/scan_result.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;
      setState(() => _imageFile = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Failed to pick image: $e", isError: true);
    }
  }

  Future<void> _detectAndSave() async {
    if (_imageFile == null) {
      showSnackBar(context, "Please select or capture a photo first.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🔍 Starting disease detection...");
      final ScanResult result = await ApiService().detectDisease(_imageFile!);
      
      print("✅ Result received:");
      print("   Disease: ${result.disease}");
      print("   Confidence: ${result.confidencePercent}%");
      print("   Crop: ${result.crop}");
      
      if (!mounted) {
        print("❌ Widget not mounted after API call");
        return;
      }

      // Save to SQLite database (don't block navigation if this fails)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          print("💾 Saving to database...");
          await DatabaseService().saveScan(user.uid, result);
          print("✅ Saved to database");
        } catch (e) {
          // Log error but don't block navigation
          print("⚠️ Error saving to database: $e");
        }
      } else {
        print("ℹ️ User not logged in, skipping database save");
      }

      if (!mounted) {
        print("❌ Widget not mounted after Firestore save");
        return;
      }

      print("🧭 Navigating to result screen...");
      print("   Result disease: ${result.disease}");
      print("   Result confidence: ${result.confidencePercent}%");
      
      // Pass result directly to constructor for reliability
      if (!mounted) return;
      
      final navigated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
      
      print("✅ Navigation completed, returned: $navigated");
      
      // Refresh if needed when returning
      if (mounted) {
        setState(() {});
      }

    } catch (e, stackTrace) {
      print("❌ Error in _detectAndSave: $e");
      print("Stack trace: $stackTrace");
      if (!mounted) return;
      showSnackBar(context, "Detection failed: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print("🔄 Loading state reset");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Upload or Capture a Crop Photo",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        /// ✅ FIXED — replaced withValues()
                        color: Colors.black12.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  height: 300,
                  width: double.infinity,
                  child: _imageFile == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_search_rounded,
                          color: Colors.grey.shade400, size: 70),
                      const SizedBox(height: 12),
                      Text("No image selected",
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.science_rounded),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    _isLoading ? "Detecting..." : "Detect Disease",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _detectAndSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
