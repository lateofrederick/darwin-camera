import 'package:darwin_camera/core/picture_object.dart';
import 'package:darwin_camera/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraViewModel with ChangeNotifier {
  List<PictureObject> objects = [
    PictureObject(
        shortCode: 'FR',
        longCode: 'Front Right',
        representation: 'assets/images/FR.png'),
    PictureObject(
        shortCode: 'RS',
        longCode: 'Right Side',
        representation: 'assets/images/right_side_thick_7.png'),
    PictureObject(
        shortCode: 'RR',
        longCode: 'Rear Right',
        representation: 'assets/images/Right_Rear_Thick_6.png'),
    PictureObject(
        shortCode: 'REAR',
        longCode: 'Rear',
        representation: 'assets/images/Rear_thick.png'),
    PictureObject(
        shortCode: 'LR',
        longCode: 'Left Rear',
        representation: 'assets/images/Left_Rear_Thick_4.png'),
    PictureObject(
        shortCode: 'LS',
        longCode: 'Left Side',
        representation: 'assets/images/left_side_thick_3.png'),
    PictureObject(
        shortCode: 'FL',
        longCode: 'Front Left',
        representation: 'assets/images/Front_Left_thick_2.png'),
    PictureObject(
        shortCode: 'FRONT',
        longCode: 'Front',
        representation: 'assets/images/Front_thick_1.png'),
  ];

  int _currentIndex = 0;
  int get index => _currentIndex;

  CameraViewModel() {
    _currentObject = objects[index];
  }

  ScrollController listController = ScrollController();

  PictureObject _currentObject;
  PictureObject get current => _currentObject;

  void updatePictureObject(PictureObject obj, int index) {
    _currentObject = obj;
    _currentIndex = index;
    final jumpIndex = double.tryParse(index.toString()) * 80.0;

    print('updated');
    notifyListeners();
    listController.animateTo(
      jumpIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void getNextPictureObject() {
    if (_currentIndex < objects.length - 1) {
      _currentIndex++;
      _currentObject = objects[_currentIndex];
      globalPictureObject = objects[_currentIndex];

      notifyListeners();

      final jumpIndex = double.tryParse(_currentIndex.toString()) * 80.0;

      listController.animateTo(
        jumpIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void toggleDamaged() {
    _currentObject.isDamaged = !_currentObject.isDamaged;
    notifyListeners();
  }

  void resetDamaged() {
    _currentObject.isDamaged = false;
    notifyListeners();
  }
}
