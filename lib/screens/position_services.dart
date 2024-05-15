import 'dart:async';
import 'dart:convert';
import 'package:car_parking_locator/reusable/reusable_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_database/firebase_database.dart';

class PositionServices {
  final String API_KEY = 'AIzaSyBjnqn8CRZYns69EfYKouEc93m7TBcHsMU';
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<String?> getPlaceId(String searchInput) async {
    try {
      final String url =
          '$baseUrl/findplacefromtext/json?input=$searchInput&inputtype=textquery&key=$API_KEY';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty) {
          return jsonResponse['candidates'][0]['place_id'];
        } else {
          return null;
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String place) async {
    final placeId = await getPlaceId(place);
    final String url = "$baseUrl/details/json?place_id=$placeId&key=$API_KEY";
    var response = await http.get(Uri.parse(url));
    var jsonResponse = convert.jsonDecode(response.body);
    var placeDetails = jsonResponse['result'] as Map<String, dynamic>;
    return placeDetails;
  }

  Future<Map<String, dynamic>> getRoutes(
      String origin, String destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?destination=$destination&origin=$origin&key=$API_KEY';
    var response = await http.get(Uri.parse(url));
    var jsonResponse = convert.jsonDecode(response.body);
    print(jsonResponse);
    var routeDetails = {
      'bounds_northeast': jsonResponse['routes'][0]['bounds']['northeast'],
      'bounds_southwest': jsonResponse['routes'][0]['bounds']['southwest'],
      'start_location': jsonResponse['routes'][0]['legs'][0]['start_location'],
      'end_location': jsonResponse['routes'][0]['legs'][0]['end_location'],
      'polyline': jsonResponse['routes'][0]['overview_polyline']['points'],
      'polyline_points': PolylinePoints().decodePolyline(
          jsonResponse['routes'][0]['overview_polyline']['points'])
    };

    return routeDetails;
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>?> getCarLocations() async {
    Map<String, dynamic> dataMap = {};
    final ref = FirebaseDatabase.instance.ref();
    try {
      final snapshot = await ref.child('carLocation').get();
      if (snapshot.exists) {
        dataMap.addAll({
          'latitude': snapshot.child('latitude').value,
          'logtitude': snapshot.child('longitude').value,
        });
      } else {
        print('No data available.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return dataMap;
  }
}
