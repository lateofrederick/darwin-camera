import 'dart:io';

class PictureObject {
  String shortCode;
  String longCode;
  String representation;
  File image;

  PictureObject({
    this.shortCode,
    this.longCode,
    this.representation,
    this.image,
  });

  @override
  String toString() => '''
    {
      shortCode: $shortCode,
      longCode: $longCode,
      rep: $representation,
      image: ${image.path}
    }
  ''';
}
