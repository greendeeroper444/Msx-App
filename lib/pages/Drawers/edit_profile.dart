import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:msx_app/database/authstore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  String _newUsername = "";
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(),

            const SizedBox(height: 16.0),

            _buildUsernameForm(),

            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () async {
                await _updateProfile();
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(){
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 80.0,
          backgroundImage: _image != null ? FileImage(_image!) : null,
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: (){
            _pickImage();
          },
        ),
      ],
    );
  }

  Widget _buildUsernameForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Update Username', style: TextStyle(fontSize: 16.0)),
        TextFormField(
          controller: _usernameController,
          onChanged: (value){
            setState(() {
              _newUsername = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async{
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if(result != null && result.files.isNotEmpty){
        setState((){
          _image = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _updateProfile() async{
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        //Update username
        await AuthStore().editUserProfile(
          uid: user.uid,
          newUsername: _newUsername,
        );

        //update profile image
        if(_image != null){
          //upload image to Firebase Storage
          final imageUrl = await AuthStore().uploadProfileImage(user.uid, _image!);

          //update profile image URL in Firestore
          if(imageUrl != null){
            await AuthStore().editUserProfile(
              uid: user.uid,
              newProfileImageUrl: imageUrl,
            );
          } else{
            print("Failed to upload profile image");
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );
      }else{
        print("User is not signed in");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
