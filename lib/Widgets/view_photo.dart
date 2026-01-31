import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhoto extends StatefulWidget {
  ViewPhoto({Key? key, this.uri, this.origin}) : super(key: key);
  String? uri;
  String? origin;

  // Método para actualizar la imagen
  void updateImage({required String newUri, required String newOrigin}) {
    uri = newUri;
    origin = newOrigin;
  }

  @override
  State<ViewPhoto> createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  late ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    if (widget.origin == 'assets') {
      imageProvider = AssetImage(widget.uri!);
    } else if (widget.origin == 'file') {
      imageProvider = FileImage(File(widget.uri!));
    } else {
      imageProvider = NetworkImage(widget.uri!);
    }

    return Row(
      children: [
        Expanded(
          child: PhotoView(
            imageProvider: imageProvider,
          ),
        ),
      ],
    );
  }
}
