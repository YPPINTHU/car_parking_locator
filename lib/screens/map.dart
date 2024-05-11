import 'dart:async';
import 'package:car_parking_locator/screens/position_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CarParkingMap extends StatefulWidget {
  const CarParkingMap({super.key});

  @override
  State<CarParkingMap> createState() => _CarParkingMapState();
}

class _CarParkingMapState extends State<CarParkingMap> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _manyMarkers = <Marker>{};
  Set<Polyline> _polylines = <Polyline>{};
  Uint8List? markerIcon;
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  void _addMarker(LatLng markerPoints) {
    setState(() {
      _manyMarkers.add(Marker(
        markerId: MarkerId('Marker ${_manyMarkers.length + 1}'),
        position: LatLng(markerPoints.latitude, markerPoints.longitude),
        infoWindow: InfoWindow(
            title: 'Position ${_manyMarkers.length + 1}',
            snippet:
                'Latitude is ${markerPoints.latitude}, Longitude is ${markerPoints.longitude}'),
        draggable: true,
      ));
    });
  }

  void _addRoutePolylines(List<PointLatLng> points) {
    _polylines.add(Polyline(
      polylineId: PolylineId('Polyline ${_polylines.length + 1}'),
      color: Colors.red,
      width: 2,
      points: points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
    ));
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  /*-- get Image from assets then convert into uint8list type --*/
  Future<Uint8List> getMarkerIcon(String image, int size) async {
    ByteData data = await rootBundle.load(image);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: size);
    ui.FrameInfo info = await codec.getNextFrame();
    return (await info.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
        backgroundColor: Color.fromRGBO(248, 215, 58, 1.0),
      ),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          hintText: 'Origin',
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          hintText: 'Destination',
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[600]),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        var route = await PositionServices().getRoutes(
                            _originController.text,
                            _destinationController.text);
                        _goToPlace(
                          route['start_location']['lat'],
                          route['start_location']['lng'],
                          route['end_location']['lat'],
                          route['end_location']['lng'],
                          route['bounds_northeast'],
                          route['bounds_southwest'],
                        );

                        _addRoutePolylines(route['polyline_points']);
                      },
                      child: Text('Search Route'))
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _manyMarkers,
              polylines: _polylines,
              // markers: {myMarker},
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (position) async {
                _addMarker(position);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Position currentPosition =
              await PositionServices().getCurrentPosition();
          _goCurrentPosition(
              currentPosition.latitude, currentPosition.longitude);
        },
        child: Icon(Icons.pin_drop),
      ),
    );
  }

  Future<void> _goToPlace(
      double start_lat,
      double start_lng,
      double end_lat,
      double end_lng,
      Map<String, dynamic> boundNE,
      Map<String, dynamic> boundSW) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(start_lat, start_lng), zoom: 2)));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundSW['lat'], boundSW['lng']),
          northeast: LatLng(boundNE['lat'], boundNE['lng']),
        ),
        25));

    _addMarker(LatLng(start_lat, start_lng));
    _addMarker(LatLng(end_lat, end_lng));
  }

  Future<void> _goCurrentPosition(
    double start_lat,
    double start_lng,
  ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(start_lat, start_lng), zoom: 2)));
    _addMarker(LatLng(start_lat, start_lng));
  }
}
