import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
// import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPhotos extends StatefulWidget {
  const AddPhotos({super.key, required this.title, required this.username});

  final String title;
  final String username;

  @override
  State<AddPhotos> createState() => _MyAddPhotosState();
}

class _MyAddPhotosState extends State<AddPhotos> {

  Image? _image;

  Future<void> _getImage() async {
    Image? fromPicker = await ImagePickerWeb.getImageAsWidget();
    if (fromPicker != null) {
      setState(() {
        _image = fromPicker;
      });
    } else {
      if (kDebugMode) {
        print("No image selected");
      }
    }
  }

  // Future<void> _upload() async {
  //   if(_image != null){
  //     final String downloadURL = await _uploadFile(widget.username);
  //   }
  // }

  // Future<String> _uploadFile(String filename) async {
  //   Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
  //   final metadata = SettableMetadata(
  //     contentType: 'image/jpeg',
  //     contentLanguage: 'en',
  //   );
  //   final UploadTask uploadTask = ref.putFile(_image.file!, metadata);
  //   TaskSnapshot uploadResult = await uploadTask;
  //   final String downloadURL = await uploadResult.ref.getDownloadURL();
  //   return downloadURL;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _image == null
              ? const Text("no image selected")
              : _image!,
            ElevatedButton(
              onPressed: _getImage,
              child: const Text(
                'Take a Photo',
                style: TextStyle(fontSize: 20),
              ),
            ),
            // ElevatedButton(
            //   onPressed: _upload,
            //   style: const ButtonStyle(
            //     backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey),
            //   ),
            //   child: const Text('Upload Photo'),
            // ),
          ],
        ),
      ),
    );
  }
}
