import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/interactive_maps_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/reports.dart';

class MapScreen extends StatelessWidget {
  static const routeName = '/map-screen';

  Future<void> _getLocations(BuildContext context) async {
    await Provider.of<Reports>(context, listen: false).fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ekibim Nerede ?'),
      ),
      body: FutureBuilder(
        future: _getLocations(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<Reports>(
                    builder: (ctx, locationsData, _) => InteractiveMapsMarker(
                      items: locationsData.markersList,
                      center: LatLng(40.77182120256615, 29.966424681822193),
                      itemContent: (context, index) {
                        MarkerItem item = locationsData.markersList[index];
                        return BottomTile(item: item);
                      },
                    ),
                  ),
      ),
      drawer: AppDrawer(),
    );
  }
}

class BottomTile extends StatelessWidget {
  const BottomTile({@required this.item});

  final MarkerItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          item.imageUrl != null
              ? Container(
                  height: 86.00,
                  width: 86.00,
                  margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(item.imageUrl),
                    ),
                    borderRadius: BorderRadius.circular(5.00),
                  ),
                )
              : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${item.employeeName}",
                      style: Theme.of(context).textTheme.headline5),
                  Expanded(
                    child: Text('${item.description}'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
