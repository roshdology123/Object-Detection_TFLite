import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = '';
  late CameraImage cameraImage;
  late CameraController cameraController;

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/mobilenet_v1_1.0_224.txt');
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController.startImageStream((imagesFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  cameraImage = imagesFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      result = '';
      recognitions?.forEach((response) {
        result += response['label'] +
            "   " +
            (response['confidence'] as double).toStringAsFixed(2) +
            '\n\n';
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.red),
        child: Column(
          children: [
            Stack(children: [
              Center(
                child: Container(
                  height: 320,
                  width: 360,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    initCamera();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 35),
                    height: 270,
                    width: 360,
                    child: cameraImage == null
                        ? Container(
                            height: 270,
                            width: 360,
                            child: Icon(
                              Icons.photo_camera_front,
                              color: Colors.blue,
                              size: 40,
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                          ),
                  ),
                ),
              ),
            ]),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 55.0),
                child: SingleChildScrollView(
                  child: Text(
                    result,
                    style: TextStyle(
                      backgroundColor: Colors.black87,
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
