import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/helpers/location_helper.dart';
import 'package:flutter_complete_guide/providers/reports.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReportDetailScreen extends StatefulWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/report-detail';

  @override
  _ReportDetailScreenState createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String _previewImageUrl;
  final dateFormat = new DateFormat("yyyy-MM-dd");
  final timeFormat = new DateFormat("HH:mm");

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedReport = Provider.of<Reports>(
      context,
      listen: false,
    ).findByTaskId(taskId);
    _showPreview(
        loadedReport.location.latitude, loadedReport.location.longitude);

    final reportDate = dateFormat.format(loadedReport.reportDate);
    final reportHour = (loadedReport.reportHour.hour).toString() +
        ':' +
        loadedReport.reportHour.minute.toString().padLeft(2, '0');
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      appBar: AppBar(
        title: Text('Rapor Detayları'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 170,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _previewImageUrl == null
                          ? Text(
                              'Konum Seçilmemiş',
                              textAlign: TextAlign.center,
                            )
                          : Image.network(
                              _previewImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Adres: ${loadedReport.location.address}"),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 400,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(loadedReport.reportImageUrl),
                        ),
                        borderRadius: BorderRadius.circular(5.00),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Açıklama: ${loadedReport.reportDescription}"),
                    Text("Rapor Tarihi: ${reportDate} ${reportHour}"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
