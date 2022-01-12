import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:darwin_camera/core/camera_view_model.dart';
import 'package:darwin_camera/core/core.dart';
import 'package:darwin_camera/core/helper.dart';
import 'package:darwin_camera/core/picture_object.dart';
import 'package:darwin_camera/globals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final Widget nextFooterButton;
  final bool showVehicleOutline;

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
    @required this.nextFooterButton,
    this.showVehicleOutline,
  }) : super(key: key);

  @override
  _RenderCameraStreamState createState() => _RenderCameraStreamState();
}

class _RenderCameraStreamState extends State<RenderCameraStream> {
  PictureObject currentObj;
  Orientation orientation;

  @override
  void initState() {
    super.initState();
    globalPictureObject = context.read<CameraViewModel>().objects[0];
  }

  @override
  Widget build(BuildContext context) {
    currentObj = context.watch<CameraViewModel>().current;
    orientation = MediaQuery.of(context).orientation;

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
            widget.showVehicleOutline ? showCarOutline() : Container(),
            widget.showVehicleOutline ? imageControls() : Container(),
            getFooter(widget.showFooter),
          ],
        ),
      ),
    );
  }

  Widget imageControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        child: ListView.builder(
          controller: Provider.of<CameraViewModel>(context).listController,
          scrollDirection: Axis.horizontal,
          itemCount: Provider.of<CameraViewModel>(context).objects.length,
          itemBuilder: (BuildContext context, int index) {
            var e = Provider.of<CameraViewModel>(context).objects[index];
            return Container(
              height: 80,
              margin: EdgeInsets.all(8.0),
              child: Material(
                child: GestureDetector(
                  onTap: () {
                    globalPictureObject = e;
                    context
                        .read<CameraViewModel>()
                        .updatePictureObject(e, index);
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
                        Visibility(
                          visible: index ==
                              Provider.of<CameraViewModel>(context).index,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget showCarOutline() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        child: orientation == Orientation.landscape
            ? Transform.scale(
                scale: 1.2,
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: Image.asset(
                    currentObj.representation,
                    package: 'darwin_camera',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            : Transform.scale(
                scale: 0.8,
                child: Image.asset(
                  currentObj.representation,
                  package: 'darwin_camera',
                  fit: BoxFit.scaleDown,
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
    // Size size = MediaQuery.of(context).size;
    final double cameraAspectRatio = widget.cameraController.value.aspectRatio;

    ///
    return ClipRect(
      child: Container(
        child: Center(
          child: orientation == Orientation.landscape
              ? CameraPreview(widget.cameraController)
              : CameraPreview(widget.cameraController),
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
        nextButton: widget.nextFooterButton,
      ),
    );
  }
}

class RenderCapturedImage extends StatefulWidget {
  final File file;

  ///
  final Widget leftFooterButton;
  final Widget centerFooterButton;
  final Widget rightFooterButton;
  final Widget nextButton;
  final VoidCallback onCropPressed;
  final VoidCallback onFilterPressed;
  final VoidCallback onDamagedPressed;

  ///
  const RenderCapturedImage({
    Key key,
    @required this.file,
    @required this.leftFooterButton,
    @required this.centerFooterButton,
    @required this.rightFooterButton,
    @required this.nextButton,
    this.onFilterPressed,
    this.onCropPressed,
    this.onDamagedPressed,
  }) : super(key: key);

  @override
  _RenderCapturedImageState createState() => _RenderCapturedImageState();
}

class _RenderCapturedImageState extends State<RenderCapturedImage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: DarwinBlack,
              height: double.infinity,
              child: Image.file(
                widget.file,
                fit: BoxFit.contain,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ),
          CameraFooter(
            leftButton: widget.leftFooterButton,
            centerButton: widget.centerFooterButton,
            rightButton: widget.rightFooterButton,
            nextButton: widget.nextButton,
          ),
          controlsHeader(),
        ],
      ),
    );
  }

  Widget controlsHeader() {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(top: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.crop, color: Colors.white),
                onPressed: widget.onCropPressed ?? null,
              ),
            ),
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.photo_filter, color: Colors.white),
                onPressed: widget.onFilterPressed ?? null,
              ),
            ),
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.warning,
                    color:
                        Provider.of<CameraViewModel>(context).current.isDamaged
                            ? Colors.yellow
                            : Colors.white),
                onPressed: () {
                  Provider.of<CameraViewModel>(context).toggleDamaged();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraFooter extends StatefulWidget {
  final Widget leftButton;
  final Widget centerButton;
  final Widget rightButton;
  final Widget nextButton;

  CameraFooter({
    Key key,
    @required this.leftButton,
    @required this.centerButton,
    @required this.rightButton,
    this.nextButton,
  }) : super(key: key);

  @override
  _CameraFooterState createState() => _CameraFooterState();
}

class _CameraFooterState extends State<CameraFooter> {
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              widget.leftButton,
              widget.centerButton,
              widget.rightButton,
              widget.nextButton,
            ],
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatefulWidget {
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
  _CancelButtonState createState() => _CancelButtonState();
}

class _CancelButtonState extends State<CancelButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap();
        }
      },
      child: Container(
        padding: widget.padding,
        child: Opacity(
          opacity: widget.opacity,
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

class AddButton extends StatefulWidget {
  final Function onTap;

  AddButton({Key key, this.onTap});

  @override
  _AddButtonState createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap();
          Provider.of<CameraViewModel>(context).resetDamaged();
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

class NextButton extends StatefulWidget {
  final Function onTap;
  final bool showNextButton;

  NextButton({Key key, this.onTap, this.showNextButton = false});

  @override
  _NextButtonState createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.showNextButton,
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          Provider.of<CameraViewModel>(context, listen: false)
              .getNextPictureObject();
        },
        child: Container(
          child: Icon(
            Icons.arrow_forward,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
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

class CaptureButton extends StatefulWidget {
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
  _CaptureButtonState createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: getButtonBody(),
      onTap: widget.onTap,
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
            width: widget.buttonSize,
            height: widget.buttonSize,
            decoration: BoxDecoration(
              color: DarwinWhite.withOpacity(0.25),
              borderRadius: BorderRadius.circular(grid_spacer * 12),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            top: widget.buttonPosition,
            left: widget.buttonPosition,
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

class ConfirmButton extends StatefulWidget {
  final Function onTap;
  const ConfirmButton({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  @override
  _ConfirmButtonState createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
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
        if (widget.onTap != null) {
          widget.onTap();
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
class ToggleCameraButton extends StatefulWidget {
  final Function onTap;
  final double opacity;
  const ToggleCameraButton({
    Key key,
    @required this.onTap,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  _ToggleCameraButtonState createState() => _ToggleCameraButtonState();
}

class _ToggleCameraButtonState extends State<ToggleCameraButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: padding_a_s,
        child: Opacity(
          opacity: widget.opacity,
          child: Icon(
            Icons.refresh,
            color: DarwinWhite,
            size: grid_spacer * 4,
          ),
        ),
      ),
      onTap: widget.onTap,
    );
  }
}

class LoaderOverlay extends StatefulWidget {
  LoaderOverlay({Key key, bool visible, String helperText}) : super(key: key);

  @override
  _LoaderOverlayState createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<LoaderOverlay> {
  bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
