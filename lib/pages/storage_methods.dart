import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage
        .ref()
        .child(childName)
        .child(_auth.currentUser!.email!.substring(0, 8));
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> removeImageFromStorage(String childName) async {
    Reference ref = _storage
        .ref()
        .child(childName)
        .child(FirebaseAuth.instance.currentUser!.email!.substring(0, 8));
    try {
      await ref.delete();
      print("Succesfully deleted image");
    } catch (err) {
      print(err.toString());
    }
  }
}
