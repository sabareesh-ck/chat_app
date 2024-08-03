import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});
  final void Function(File selectedimage) onPickImage;
  @override
  State<UserImagePicker> createState() {
    // TODO: implement createState
    return _UserImagePicker();
  }
}

class _UserImagePicker extends State<UserImagePicker> {
  File? pickedImageFile;
  void pickimage() async {
    final pickedimage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedimage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedimage.path);
    });
    widget.onPickImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedImageFile == null ? null : FileImage(pickedImageFile!),
        ),
        TextButton.icon(
            onPressed: pickimage,
            icon: const Icon(Icons.image),
            label: Text(
              "Add Image",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
