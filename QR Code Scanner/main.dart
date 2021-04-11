import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:string_validator/string_validator.dart';

void main(){
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CodeScanner(),
    );
  }
}

class CodeScanner extends StatefulWidget {
  const CodeScanner({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> {
  Barcode result;
  int counter = 0;

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(title: Text('QR Code Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQrView(context)
          ),
        ],
      ),
    );
  }

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controller.resumeCamera();
  //   }
  // }



  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void refreshData() {
    counter = 0;
  }

  void onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      setState(()  {
        print("inside setState.....$counter");
        if (result.code.isNotEmpty && counter == 0){
          counter = counter + 1;
          if(isURL(result.code)){
            _launchURL(result.code);
          }else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: result.code),
              ),
            ).then(onGoBack);
          }
        }
      });
    },
    );
  }

    void _launchURL(String url) async {
    if (await canLaunch(url)) {
       launch(url).then(onGoBack);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    if (result.code != null) {
      controller.dispose();
      super.dispose();
    }
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Center( child : new Text(imagePath, style: new TextStyle( fontSize: 30.0, color: Colors.redAccent,),
        ))
    );
  }
}