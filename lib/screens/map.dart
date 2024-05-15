import 'dart:async';
import 'package:car_parking_locator/reusable/reusable_widgets.dart';
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
import 'package:firebase_database/firebase_database.dart';
import '../reusable/reusable_methods.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;
import 'package:firebase_auth/firebase_auth.dart';

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
  Placemark _address = Placemark();
  Uint8List? markerIcon;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  void _addMarker(LatLng markerPoints) {
    setState(() {
      _manyMarkers.add(Marker(
        markerId: MarkerId('Marker ${_manyMarkers.length + 1}'),
        position: LatLng(markerPoints.latitude, markerPoints.longitude),
        infoWindow: InfoWindow(
            title: _address == null
                ? 'Position ${_manyMarkers.length + 1}'
                : '${_address.street}',
            snippet: _address == null
                ? 'Latitude is ${markerPoints.latitude}, Longitude is ${markerPoints.longitude}'
                : '${_address.street},${_address.postalCode},${_address.administrativeArea},${_address.country}'),
        draggable: true,
      ));
    });
  }

  Future<void> _addCarMarker(LatLng markerPoints) async {
    final Uint8List carIcon =
        await getMarkerIcon("assets/images/marker_car.png", 100);
    setState(() {
      _manyMarkers.add(Marker(
        icon: BitmapDescriptor.fromBytes(carIcon),
        markerId: MarkerId('Marker ${_manyMarkers.length + 1}'),
        position: LatLng(markerPoints.latitude, markerPoints.longitude),
        infoWindow: InfoWindow(
            title: _address == null
                ? 'Position ${_manyMarkers.length + 1}'
                : '${_address.street}',
            snippet: _address == null
                ? 'Latitude is ${markerPoints.latitude}, Longitude is ${markerPoints.longitude}'
                : '${_address.street},${_address.postalCode},${_address.administrativeArea},${_address.country}'),
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
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
        backgroundColor: Color.fromRGBO(248, 215, 58, 1.0),
        actions: [
          IconButton(
              onPressed: () async {
                PositionServices().getCarLocations();
                Map<String, dynamic>? currentPosition =
                    await PositionServices().getCarLocations();
                _goCurrentPosition(currentPosition!['latitude'],
                    currentPosition['logtitude'], 'car');
              },
              icon: Icon(Icons.find_replace)),
          IconButton(
              onPressed: () async {
                Position currentPosition =
                    await PositionServices().getCurrentPosition();
                _goCurrentPosition(
                    currentPosition.latitude, currentPosition.longitude, 'car');
                saveCarLocation(
                    currentPosition.latitude, currentPosition.longitude);
              },
              icon: Icon(Icons.directions_car_outlined)),
          IconButton(
              onPressed: () async {
                signOutUser(_auth, context);
              },
              icon: Icon(Icons.logout_outlined))
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            controller: _searchController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Search place..',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[500],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            var searchLocation = await PositionServices()
                                .getPlaceDetails(_searchController.text);

                            print(
                                searchLocation['geometry']['location']['lat']);
                            print(
                                searchLocation['geometry']['location']['lng']);

                            _goCurrentPosition(
                                searchLocation['geometry']['location']['lat'],
                                searchLocation['geometry']['location']['lng'],
                                'user');
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
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
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Origin',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[500],
                      ),
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
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[500],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_originController.text.isNotEmpty &&
                            _destinationController.text.isNotEmpty) {
                          var route = await PositionServices().getRoutes(
                              _originController.text,
                              _destinationController.text);
                          double distance = Geolocator.distanceBetween(
                            route['start_location']['lat'],
                            route['start_location']['lng'],
                            route['end_location']['lat'],
                            route['end_location']['lng'],
                          );
                          print(distance);
                          _goToPlace(
                            route['start_location']['lat'],
                            route['start_location']['lng'],
                            route['end_location']['lat'],
                            route['end_location']['lng'],
                            route['bounds_northeast'],
                            route['bounds_southwest'],
                          );

                          _addRoutePolylines(route['polyline_points']);
                        } else {
                          showInformation(
                              context, 'provide origin and destination  ');
                        }
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
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    position.latitude, position.longitude);
                print(placemarks[0]);
                _address = placemarks[0];
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
              currentPosition.latitude, currentPosition.longitude, 'user');
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
      double start_lat, double start_lng, String type) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(start_lat, start_lng), zoom: 13)));
    if (type == 'car') {
      _addCarMarker(LatLng(start_lat, start_lng));
    } else {
      _addMarker(LatLng(start_lat, start_lng));
    }
  }

  void saveCarLocation(double latitude, double longitude) {
    final database = FirebaseDatabase.instance.ref();
    var locationRef = database.child('carLocation');
    var now = DateTime.now();
    String formattedTime = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    Map<String, dynamic> location = {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': formattedTime,
    };

    locationRef.update(location).then((_) {
      showToast('Car location saved successfully');
    }).catchError((error) {
      showToast('Failed to save car location');
      print('Failed to save car location: $error');
    });
  }

  void saveUserLocation(double latitude, double longitude) {
    final database = FirebaseDatabase.instance.ref();
    var locationRef = database.child('userLocation');
    var now = DateTime.now();
    String formattedTime = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    locationRef.child(formattedTime).set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': formattedTime,
    }).then((_) {
      showToast('user location saved successfully');
    }).catchError((error) {
      showToast('Failed to save user location');
      print('Failed to save user location: $error');
    });
  }

  void _startLocationTracking() {
    const tenMinutes = Duration(minutes: 10);
    Timer.periodic(tenMinutes, (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      saveUserLocation(position.latitude, position.longitude);
    });
  }
}
