import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:college_project/Themes/theme_provider.dart';
import 'package:college_project/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser!;
  File? profileImageFile;

  String name = '';
  String goal = '';
  String? profileImageURL;
  bool isLoading = true;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? '';
          goal = data['goal'] ?? '';
          profileImageURL = data['profileImageURL'];
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': 'New User',
          'goal': 'Set a goal',
          'profileImageURL': null,
        });
        setState(() { // Also update state if a new user profile is created
          name = 'New User';
          goal = 'Set a goal';
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) { // Check mounted state before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          profileImageFile = File(pickedFile.path);
        });
        await _uploadProfileImageToCloudinary(profileImageFile!);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfileImageToCloudinary(File imageFile) async {
    const cloudName = 'dswpsld8n';
    const uploadPreset = 'profilepic';

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final resStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resStr);
        final downloadURL = data['secure_url'];

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImageURL': downloadURL,
        });

        setState(() => profileImageURL = downloadURL);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } else {
        print('Upload failed: ${response.statusCode} - $resStr');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${response.statusCode}')), // More concise message
          );
        }
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error during upload: $e')),
        );
      }
    }
  }

  // --- Start of _showEditProfileModal FIX (Functional Changes Only) ---
  void _showEditProfileModal() {
    final nameController = TextEditingController(text: name);
    final goalController = TextEditingController(text: goal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Essential for keyboard to push modal up
      builder: (BuildContext context) { // Use BuildContext from builder to get proper MediaQuery
        return LayoutBuilder( // Allows to get parent constraints to size the modal content
          builder: (BuildContext context, BoxConstraints constraints) {
            final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            // Calculate maximum height for the modal content, leaving some space
            final double maxModalContentHeight = constraints.maxHeight * 0.9; // Adjusted to 90%

            return ConstrainedBox( // Constrain the height of the modal's content
              constraints: BoxConstraints(
                maxHeight: maxModalContentHeight,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight), // Push modal up by keyboard height
                child: Container(
                  padding: const EdgeInsets.all(20),
                  // Removed explicit height, relying on ConstrainedBox and Column's mainAxisSize.min
                  decoration: BoxDecoration( // Added decoration for modal background (important to prevent transparent overflow on theme change)
                    color: Theme.of(context).canvasColor, // Use theme's canvas color for modal background
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView( // Makes the content *inside* the modal scrollable
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Column takes minimum vertical space
                      children: [
                        // Title
                        Text(
                          'Edit Profile',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Name TextField
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          // No UI changes: textCapitalization: TextCapitalization.words, // Added for UX, but optional
                        ),
                        const SizedBox(height: 10),

                        // Email TextField (disabled)
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: user.email,
                            hintStyle: const TextStyle(color: Colors.grey),
                            disabledBorder: const OutlineInputBorder(),
                            // No UI changes: Added explicit enabled/focused borders for consistency
                            // enabledBorder: const OutlineInputBorder(),
                            // focusedBorder: const OutlineInputBorder(),
                          ),
                          // No UI changes: style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),

                        // Goal TextField
                        TextField(
                          controller: goalController,
                          decoration: const InputDecoration(labelText: 'Your Goal'),
                          maxLines: 2, // Retained your original maxLines
                          // No UI changes: minLines: 1, // Added for UX, but optional
                          // No UI changes: keyboardType: TextInputType.multiline, // Added for UX, but optional
                        ),
                        const SizedBox(height: 20),

                        // Save Changes Button
                        ElevatedButton(
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            final newGoal = goalController.text.trim();

                            if (newName != name || newGoal != goal) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'name': newName,
                                  'goal': newGoal,
                                });

                                setState(() {
                                  name = newName;
                                  goal = newGoal;
                                });
                                if (mounted) { // Check mounted state before popping
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile updated successfully!')),
                                  );
                                }
                              } catch (e) {
                                print("Error updating profile: $e");
                                if (mounted) { // Check mounted state before showing SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update profile: $e')),
                                  );
                                }
                              }
                            } else {
                              if (mounted) Navigator.pop(context); // Close if no changes
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- End of _showEditProfileModal FIX ---

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (mounted) { // Check mounted state before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
  void _showImageSourceActionSheet() {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pick from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Picture'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    ),
  );
}

void _showImagePreviewOverlay() {
  if (_overlayEntry != null) return; // prevent duplicates

  final imageProvider = profileImageFile != null
      ? FileImage(profileImageFile!)
      : (profileImageURL != null
          ? NetworkImage(profileImageURL!)
          : const AssetImage('assets/def.jpeg') as ImageProvider);

  // Animation controller + fade transition using StatefulBuilder
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return Material(
        color: Colors.black54,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CircleAvatar(
                    radius: 120,
                    backgroundImage: imageProvider,
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  Overlay.of(context).insert(_overlayEntry!);
}


void _hideImagePreviewOverlay() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}

  @override
  Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  
  return Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      title: const Text('Profile'),
      actions: [
        Row(
          children: [
            const Icon(Icons.light_mode),
            Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
            const Icon(Icons.dark_mode),
          ],
        ),
        const SizedBox(width: 10),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onLongPressStart: (_) => _showImagePreviewOverlay(),
                        onLongPressEnd: (_)=> _hideImagePreviewOverlay(),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImageFile != null
                              ? FileImage(profileImageFile!)
                              : (profileImageURL != null
                                  ? NetworkImage(profileImageURL!)
                                  : const AssetImage('assets/def.jpeg')
                                      as ImageProvider),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showImageSourceActionSheet,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child:
                                const Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(name, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 10),
                Text(user.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Text("Goal: $goal",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showEditProfileModal,
                  child: const Text("Edit Profile"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
  );
}

}