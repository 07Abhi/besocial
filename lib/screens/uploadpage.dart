import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:besocial/widgets/progressbars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:besocial/model/usermodel.dart';

ImagePicker picker = new ImagePicker();

class Upload extends StatefulWidget {
  final UserData currentUserData;

  Upload({this.currentUserData});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final textCaptionController = TextEditingController();
  final textLocationController = TextEditingController();

  //PickedFile file;
  File imageFile;
  bool isUploading = false;
  String postId = Uuid().v4();
  bool showSpinner = false;

  getLocation() async {
    setState(() {
      showSpinner = true;
    });
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placesaccloc = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placesaccloc[0];
//    String completeplaceinfo =
//        '${place.locality},${place.name},${place.country},${place.subLocality},${place.position}';
    String precisePlace =
        '${place.subLocality}, ${place.locality}, ${place.country}';
    textLocationController.text = precisePlace;
    setState(() {
      showSpinner = false;
    });
  }

  compressImage() async {
    //the temporary directory is made when we click the image or select from the gallery.
    var getDir = await getTemporaryDirectory();
    //here we took the path of it.
    final path = getDir.path;
    Im.Image imgfile = Im.decodeImage(imageFile.readAsBytesSync());
    final compressedImgFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imgfile, quality: 85));
    setState(() {
      imageFile = compressedImgFile;
    });
  }

  Future<String> uploadImage(File imgFile) async {
    StorageUploadTask storageTask =
        storageRef.child('post_$postId.jpg').putFile(imgFile);
    StorageTaskSnapshot storageSnap = await storageTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFireStore({String medialink, String location, String caption}) {
    postRef
        .document(widget.currentUserData.id)
        .collection('userspost')
        .document(postId)
        .setData(
      {
        'postId': postId,
        'ownerId': widget.currentUserData.id,
        'username': widget.currentUserData.username,
        'mediaUrl': medialink,
        'caption': caption,
        'location': location,
        'timeStamp': timeStamp,
        'likes': {}
      },
    );
  }

  handleUpload() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(imageFile);
    createPostInFireStore(
      medialink: mediaUrl,
      location: textLocationController.text,
      caption: textCaptionController.text,
    );
    textLocationController.clear();
    textCaptionController.clear();
    setState(
      () {
        imageFile = null;
        isUploading = false;
      },
    );
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    var clickedImage = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      imageFile = File(clickedImage.path);
    });
  }

  handleGalleryPhoto() async {
    Navigator.pop(context);
    var selectedImage = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      imageFile = File(selectedImage.path);
    });
  }

  makeUpload(parentcontext) {
    return showDialog(
        context: parentcontext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Make Post',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  color: Colors.black),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: handleTakePhoto,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 16.0,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: handleGalleryPhoto,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.photo_album),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Select From Gallery',
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 16.0,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.cancel),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 16.0,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Scaffold buildsplashScreen(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.teal.withOpacity(0.6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'images/upload.svg',
                height: orientation == Orientation.portrait ? 260.0 : 200.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                height: 40.0,
                width: 200.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  onPressed: () => makeUpload(context),
                  color: Colors.deepOrange,
                  child: Text(
                    'Upload Picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Ubuntu',
                      fontSize: 18.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ModalProgressHUD buildUploadImage() {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white70,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'BeSocial',
                          style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        content: Text(
                          'Cancel Upload',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 18.0,
                            color: Colors.black54,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                imageFile = null;
                              });
                            },
                            color: Colors.teal,
                            child: Text(
                              'Discard',
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            color: Colors.teal,
                            child: Text(
                              'Keep',
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              },
              color: Colors.black87,
            ),
            title: Text(
              'Captionization',
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Ubuntu',
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: isUploading
                        ? null
                        : () {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            handleUpload();
                          },
                    child: Text(
                      isUploading ? '' : 'Post',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              isUploading ? linearProgress() : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  height: 220.0,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(imageFile),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(
                      widget.currentUserData.photoUrl),
                ),
                title: Container(
                  width: 250.0,
                  child: TextField(
                    controller: textCaptionController,
                    decoration: InputDecoration(
                      hintText: 'Your Caption.....',
                      hintStyle: TextStyle(fontFamily: 'Ubuntu'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                height: 1.5,
                color: Colors.blueGrey,
              ),
              SizedBox(
                height: 10.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.deepOrange,
                  size: 35.0,
                ),
                title: Container(
                  width: 250.0,
                  child: TextField(
                    controller: textLocationController,
                    decoration: InputDecoration(
                      hintText: 'Location.....',
                      hintStyle: TextStyle(fontFamily: 'Ubuntu'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 70.0, right: 70.0, top: 30.0),
                child: RaisedButton(
                  onPressed: getLocation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        'Use device location',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildsplashScreen(context) : buildUploadImage();
  }
}
