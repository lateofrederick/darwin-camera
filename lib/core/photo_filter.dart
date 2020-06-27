import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;

import 'package:path/path.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/photofilters.dart';

class PhotoFilterScreen extends StatefulWidget {
  final File image;
  PhotoFilterScreen(this.image, {Key key}) : super(key: key);

  @override
  _PhotoFilterScreenState createState() => _PhotoFilterScreenState();
}

class _PhotoFilterScreenState extends State<PhotoFilterScreen> {
  List<Filter> filters = presetFiltersList;
  String fileName;
  imageLib.Image image;

  @override
  void initState() {
    super.initState();

    _prepImage();
  }

  _prepImage() {
    fileName = basename(widget.image.path);
    image = imageLib.decodeImage(widget.image.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      width: 600,
      child: PhotoFilterSelector(
        title: Text('Select Filter'),
        image: image,
        filters: filters,
        filename: fileName,
        loader: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
