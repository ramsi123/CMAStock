import 'dart:io';
import 'package:cahaya_mulya_abadi/components/my_button.dart';
import 'package:cahaya_mulya_abadi/components/optional_textfield.dart';
import 'package:cahaya_mulya_abadi/services/database/database_service.dart';
import 'package:cahaya_mulya_abadi/themes/app_pallete.dart';
import 'package:cahaya_mulya_abadi/utils/pick_image.dart';
import 'package:cahaya_mulya_abadi/utils/show_snackbar.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  static route(
    String docId,
    String imageId,
    String imageUrl,
    String name,
    String email,
  ) =>
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          docId: docId,
          imageId: imageId,
          imageUrl: imageUrl,
          name: name,
          email: email,
        ),
      );

  final String docId;
  final String imageId;
  final String imageUrl;
  final String name;
  final String email;

  const EditProfilePage({
    super.key,
    required this.docId,
    required this.imageId,
    required this.imageUrl,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // database service
  final databaseService = DatabaseService();

  // name and email controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // variables
  File? image;

  // select image
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  // save edit profile
  void saveEditProfile(
    BuildContext context,
    String docId,
    String name,
    File? image,
    String imageId,
    String imageUrl,
  ) async {
    try {
      await databaseService.saveEditProfile(
        docId,
        name,
        image,
        imageId,
        imageUrl,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // initialize controllers
    _nameController.text = widget.name;
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    // dispose controllers
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  // profile picture
                  Stack(
                    children: [
                      SizedBox(
                        height: 125,
                        width: 125,
                        child: image != null
                            ? GestureDetector(
                                onTap: selectImage,
                                child: ClipOval(
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: selectImage,
                                child: widget.imageUrl.isNotEmpty
                                    ? ClipOval(
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/loading.gif',
                                          image: widget.imageUrl,
                                          width: 125,
                                          height: 125,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.asset(
                                          'assets/profile-picture.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.edit,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // name
                  OptionalTextfield(
                    controller: _nameController,
                    title: 'Nama Lengkap',
                    hintText: 'Masukkan Nama Lengkap Anda',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // email
                  OptionalTextfield(
                    controller: _emailController,
                    title: 'Email',
                    hintText: 'Masukkan Email Anda',
                    obscureText: false,
                    enabled: false,
                  ),

                  const SizedBox(height: 25),

                  // save button
                  MyButton(
                    onTap: () {
                      saveEditProfile(
                        context,
                        widget.docId,
                        _nameController.text,
                        image,
                        widget.imageId,
                        widget.imageUrl,
                      );
                      Navigator.pop(context);
                      showSnackbar(context, 'Update Profile Berhasil.');
                    },
                    text: "Simpan",
                    backgroundColor: const [
                      AppPallete.peach,
                      AppPallete.pink,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
