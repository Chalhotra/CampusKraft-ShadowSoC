import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/pages/storage_methods.dart';

import 'package:image_picker/image_picker.dart';

class ProfileDialogBox extends StatefulWidget {
  final VoidCallback onAvatarUpdated;
  const ProfileDialogBox({super.key, required this.onAvatarUpdated});

  @override
  State<ProfileDialogBox> createState() => _ProfileDialogBoxState();
}

class _ProfileDialogBoxState extends State<ProfileDialogBox> {
  bool isLoading = true;
  Uint8List? _image;

  void initImage() async {
    try {
      Uint8List? im = await FirebaseStorage.instance
          .ref()
          .child('userProfilePics')
          .child(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
          .getData();

      setState(() {
        _image = im;
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });

      print('No Image selected at the moment');
    }
  }

  pickImage(ImageSource src) async {
    ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: src);
    if (_file != null) {
      return await _file.readAsBytes();
    } else {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initImage();
  }

  void selectImage() async {
    try {
      Uint8List im = await pickImage(ImageSource.gallery);
      setState(() {
        _image = im;
      });
    } catch (err) {
      print("No IMage selected");
    }
  }

  void uploadAvatar() async {
    String photoUrl =
        await StorageMethods().uploadImageToStorage('userProfilePics', _image!);

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
        .update({'photoUrl': photoUrl});
    widget.onAvatarUpdated();
  }

  void removeAvatar() async {
    StorageMethods().removeImageFromStorage('userProfilePics');
    setState(() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email!.substring(0, 8))
          .update({'photoUrl': ""});
    });
    widget.onAvatarUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 30.0, bottom: 15.0, right: 10.0, left: 10.0),
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: Column(
            children: [
              Stack(children: [
                (_image == null && isLoading == true)
                    ? const CircleAvatar(
                        radius: 64,
                        child: CircularProgressIndicator(),
                      )
                    : (_image == null && isLoading == false)
                        ? const CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.blue,
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          ),
                Positioned(
                  bottom: -5,
                  left: 85,
                  child: Stack(children: [
                    const Positioned(
                      left: 6,
                      top: 7,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 17,
                      ),
                    ),
                    IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.camera_alt)),
                  ]),
                )
              ]),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                        side:
                            const BorderSide(color: Colors.black, width: 1.5)),
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                  TextButton(
                    onPressed: removeAvatar,
                    child: Text("Remove Avatar"),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(width: 1.5, color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      uploadAvatar();
                      Navigator.of(context).pop();
                    },
                    child: Text("Upload Avatar"),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
