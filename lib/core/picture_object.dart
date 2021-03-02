import 'dart:io';

class PictureObject {
  String shortCode;
  String longCode;
  String representation;
  File image;
  bool isDamaged;

  PictureObject(
      {this.shortCode,
      this.longCode,
      this.representation,
      this.image,
      this.isDamaged = false});

  @override
  String toString() => '''
    {
      shortCode: $shortCode,
      longCode: $longCode,
      rep: $representation,
      image: ${image.path},
      isDamaged: $isDamaged
    }
  ''';
}
