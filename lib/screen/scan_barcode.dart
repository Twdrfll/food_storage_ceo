import 'package:flutter/material.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';

class ScanBarcode extends StatefulWidget {

  @override
  ScanBarcodeState createState() => ScanBarcodeState();

}

class ScanBarcodeState extends State<ScanBarcode> {

  String scanned_barcode = '';

  String lastReadedBarcode() {
    if (scanned_barcode == '') {
      return 'in attesa...';
    } else {
      return scanned_barcode;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80.0,
        leading: SizedBox(
          width: 80.0,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scansiona Barcode',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(
              width: 60.0,
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: BarcodeCamera(
        types: [BarcodeType.ean8, BarcodeType.ean13],
        resolution: Resolution.hd720,
        mode: DetectionMode.pauseVideo,
        onScan: (barcode) {
          setState(() {
            this.scanned_barcode = barcode.value;
          });
        },
        children: [
          MaterialPreviewOverlay(animateDetection: false),
          BlurPreviewOverlay(),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ultimo barcode rilevato:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: theme.textTheme.labelMedium!.fontSize,
                      fontWeight: theme.textTheme.labelMedium!.fontWeight,
                    ),
                  ),
                  Text(
                    lastReadedBarcode(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 150.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.restart_alt,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                setState(() {
                                  scanned_barcode = '';
                                });
                                await CameraController.instance.resumeDetector();
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.check,
                                size: 40.0,
                                color: Colors.white,),
                              onPressed: () async {
                                await CameraController.instance.pauseDetector();
                                await CameraController.instance.dispose();
                                Navigator.pop(context, scanned_barcode);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}