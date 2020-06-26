import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:darwin_camera/core/core.dart';
import 'package:darwin_camera/core/helper.dart';
import 'package:darwin_camera/core/picture_object.dart';
import 'package:darwin_camera/globals.dart';
import 'package:flutter/material.dart';

double captureButtonInnerBorderRadius = grid_spacer * 10;
double captureButtonInnerShutterSize = grid_spacer * 8;
double captureButtonPosition = grid_spacer;
double captureButtonSize = grid_spacer * 10;

enum CameraState { NOT_CAPTURING, CAPTURING, CAPTURED }

class RenderCameraStream extends StatefulWidget {
  final CameraController cameraController;
  final bool showHeader;
  final bool showFooter;
  final bool disableNativeBackFunctionality;
  final Widget leftFooterButton;
  final Widget centerFooterButton;
  final Widget rightFooterButton;
  final Function onBackPress;

  RenderCameraStream({
    Key key,

    ///
    @required this.cameraController,
    @required this.showHeader,
    this.disableNativeBackFunctionality = false,
    this.onBackPress,

    ///
    @required this.showFooter,
    @required this.leftFooterButton,
    @required this.centerFooterButton,
    @required this.rightFooterButton,
  }) : super(key: key);

  @override
  _RenderCameraStreamState createState() => _RenderCameraStreamState();
}

class _RenderCameraStreamState extends State<RenderCameraStream> {
  String imageString; // = 'assets/images/right_side_thick_7.png';
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

  @override
  void initState() {
    super.initState();
    imageString = objects[0].representation;
    globalPictureObject = objects[0];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this.widget.disableNativeBackFunctionality
          ? () async {
              return false;
            }
          : null,
      child: SafeArea(
        top: true,
        child: Stack(
          children: <Widget>[
            getCameraStream(context),
            getHeader(widget.showHeader),
            getFooter(widget.showFooter),
            showCarOutline(context),
            imageControls(context),
          ],
        ),
      ),
    );
  }

  Widget imageControls(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: objects
              .map(
                (e) => Container(
                  height: 80,
                  margin: EdgeInsets.all(8.0),
                  child: Material(
                    child: GestureDetector(
                      onTap: () {
                        globalPictureObject = e;
                        imageString = e.representation;
                        setState(() {});
                      },
                      child: Transform.rotate(
                        angle: math.pi / 2,
                        child: Stack(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/camera.png',
                              package: 'darwin_camera',
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              top: 50,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                color: Colors.orange,
                                child: Text(
                                  e.longCode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget showCarOutline(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        child: Transform.scale(
          scale: 1.2,
          child: Transform.rotate(
            angle: math.pi / 2,
            child: Image.asset(
              imageString,
              package: 'darwin_camera',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// This will render stream on camera on the screen.
  /// Scaling is important here as the default camera stream
  /// isn't perfect.
  Widget getCameraStream(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double cameraAspectRatio = widget.cameraController.value.aspectRatio;

    ///
    return ClipRect(
      child: Container(
        child: Center(
          child: AspectRatio(
            aspectRatio: cameraAspectRatio,
            child: CameraPreview(widget.cameraController),
            // (cameraMode == CameraMode.BARCODE)
            //     ? Container()
            //     : previewCamera(cameraState),
          ),
        ),

        ///
        /// FIX: Provide multiple presets and aspects ratio to the users.
        // Transform.scale(
        //   scale: cameraAspectRatio / size.aspectRatio,
        //   child: Center(
        //     child: AspectRatio(
        //       aspectRatio: cameraAspectRatio,
        //       child: CameraPreview(cameraController),
        //       // (cameraMode == CameraMode.BARCODE)
        //       //     ? Container()
        //       //     : previewCamera(cameraState),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  ///
  /// Header is aligned in the top center
  /// It will show back button onf this page
  Widget getHeader(bool showHeader) {
    return Visibility(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            gradient: DarwinCameraHelper.backgroundGradient(
              Alignment.topCenter,
              Alignment.bottomCenter,
            ),
          ),
          padding: padding_x_s + padding_top_s + padding_bottom_xl,
          child: SafeArea(
            child: Row(
              children: <Widget>[
                CancelButton(
                  key: ValueKey("HeaderCancelButton"),
                  opacity: 1,
                  padding: padding_a_xs,
                  onTap: () {
                    if (widget.onBackPress != null) {
                      widget.onBackPress();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFooter(bool showFooter) {
    return Visibility(
      visible: showFooter,
      child: CameraFooter(
        leftButton: widget.leftFooterButton,
        centerButton: widget.centerFooterButton,
        rightButton: widget.rightFooterButton,
      ),
    );
  }
}

class RenderCapturedImage extends StatelessWidget {
  final File file;

  ///
  final Widget leftFooterButton;
  final Widget centerFooterButton;
  final Widget rightFooterButton;

  ///
  const RenderCapturedImage({
    Key key,
    @required this.file,
    @required this.leftFooterButton,
    @required this.centerFooterButton,
    @required this.rightFooterButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            color: DarwinBlack,
            height: double.infinity,
            child: Image.file(
              file,
              fit: BoxFit.contain,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
        ),
        CameraFooter(
          leftButton: leftFooterButton,
          centerButton: centerFooterButton,
          rightButton: rightFooterButton,
        ),
      ],
    );
  }
}

class CameraFooter extends StatelessWidget {
  final Widget leftButton;
  final Widget centerButton;
  final Widget rightButton;

  CameraFooter({
    Key key,
    @required this.leftButton,
    @required this.centerButton,
    @required this.rightButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: DarwinCameraHelper.backgroundGradient(
            Alignment.bottomCenter,
            Alignment.topCenter,
          ),
        ),
        padding: padding_x_s + padding_top_xl + padding_bottom_l,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[leftButton, centerButton, rightButton],
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  ///
  final Function onTap;
  final double opacity;
  final EdgeInsets padding;

  ///
  CancelButton({
    Key key,
    @required this.onTap,
    @required this.opacity,
    this.padding = padding_a_s,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: padding,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.cancel,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final Function onTap;

  AddButton({Key key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        child: Icon(
          Icons.add,
          color: DarwinWhite,
          size: grid_spacer * 4,
        ),
      ),
    );
  }
}

//=============================================================
//
//   ####    ###    #####   ######  ##   ##  #####    #####
//  ##      ## ##   ##  ##    ##    ##   ##  ##  ##   ##
//  ##     ##   ##  #####     ##    ##   ##  #####    #####
//  ##     #######  ##        ##    ##   ##  ##  ##   ##
//   ####  ##   ##  ##        ##     #####   ##   ##  #####
//
//
//  #####   ##   ##  ######  ######   #####   ##     ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ####   ##
//  #####   ##   ##    ##      ##    ##   ##  ##  ## ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ##    ###
//  #####    #####     ##      ##     #####   ##     ##
//
//=========================================================

class CaptureButton extends StatelessWidget {
  final double buttonSize;
  final double buttonPosition;
  final Function onTap;

  CaptureButton({
    Key key,
    @required this.buttonSize,
    @required this.buttonPosition,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: getButtonBody(),
      onTap: onTap,
    );
  }

  Widget getButtonBody() {
    return Container(
      height: grid_spacer * 14,
      width: grid_spacer * 14,
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            alignment: Alignment.center,
            duration: Duration(milliseconds: 100),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: DarwinWhite.withOpacity(0.25),
              borderRadius: BorderRadius.circular(grid_spacer * 12),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            top: buttonPosition,
            left: buttonPosition,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: grid_spacer * 8,
              height: grid_spacer * 8,
              decoration: BoxDecoration(
                color: DarwinWhite,
                borderRadius: BorderRadius.circular(grid_spacer * 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//===============================================================
//
//   ####   #####   ##     ##  #####  ##  #####    ###    ###
//  ##     ##   ##  ####   ##  ##     ##  ##  ##   ## #  # ##
//  ##     ##   ##  ##  ## ##  #####  ##  #####    ##  ##  ##
//  ##     ##   ##  ##    ###  ##     ##  ##  ##   ##      ##
//   ####   #####   ##     ##  ##     ##  ##   ##  ##      ##
//
//
//  #####   ##   ##  ######  ######   #####   ##     ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ####   ##
//  #####   ##   ##    ##      ##    ##   ##  ##  ## ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ##    ###
//  #####    #####     ##      ##     #####   ##     ##
//
//=========================================================

class ConfirmButton extends StatelessWidget {
  final Function onTap;
  const ConfirmButton({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: grid_spacer * 14,
        height: grid_spacer * 14,
        alignment: Alignment.center,
        child: Container(
          width: grid_spacer * 10,
          height: grid_spacer * 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(grid_spacer * 12),
            color: DarwinSuccess,
          ),
          child: Icon(
            Icons.check,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

//=================================================================================================================
//
//  ######   #####    ####     ####    ##      #####         ####    ###    ###    ###  #####  #####      ###
//    ##    ##   ##  ##       ##       ##      ##           ##      ## ##   ## #  # ##  ##     ##  ##    ## ##
//    ##    ##   ##  ##  ###  ##  ###  ##      #####        ##     ##   ##  ##  ##  ##  #####  #####    ##   ##
//    ##    ##   ##  ##   ##  ##   ##  ##      ##           ##     #######  ##      ##  ##     ##  ##   #######
//    ##     #####    ####     ####    ######  #####         ####  ##   ##  ##      ##  #####  ##   ##  ##   ##
//
//
//  #####   ##   ##  ######  ######   #####   ##     ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ####   ##
//  #####   ##   ##    ##      ##    ##   ##  ##  ## ##
//  ##  ##  ##   ##    ##      ##    ##   ##  ##    ###
//  #####    #####     ##      ##     #####   ##     ##
//
//=========================================================

///
///
/// This widget will send event to toggle camera.
class ToggleCameraButton extends StatelessWidget {
  final Function onTap;
  final double opacity;
  const ToggleCameraButton({
    Key key,
    @required this.onTap,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: padding_a_s,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.refresh,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class LoaderOverlay extends StatelessWidget {
  bool isVisible;

  LoaderOverlay({Key key, bool visible, String helperText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
