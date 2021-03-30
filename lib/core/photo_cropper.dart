import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class PhotoCropperScreen extends StatefulWidget {
  final File image;
  PhotoCropperScreen(this.image, {Key key}) : super(key: key);

  @override
  _PhotoCropperScreenState createState() => _PhotoCropperScreenState();
}

class _PhotoCropperScreenState extends State<PhotoCropperScreen> {
  final cropKey = GlobalKey<CropState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Crop.file(widget.image, key: cropKey),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20.0),
            alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  child: Text(
                    'Crop Image',
                  ),
                  onPressed: () => _cropImage(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: widget.image,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    Navigator.pop(context, file);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
