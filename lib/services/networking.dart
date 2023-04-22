// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkHelper {
  final String apiKey =
      '5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab';
  final String pathParam = 'driving-car'; // Change it if you want
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;
  //String url =
  //    'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&start=$startLng,$startLat&end=$endLng,$endLat';

  NetworkHelper(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  Future getData() async {
    Uri url2uri = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&start=$startLng,$startLat&end=$endLng,$endLat');

    http.Response response = await http.get(url2uri);

    //print(
    //   '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat');

    print(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&start=$startLng,$startLat&end=$endLng,$endLat');

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

class MyAutocomplete {
  final String apiKey =
      '5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab';
  final String place;

  MyAutocomplete({
    required this.place,
  });


  Future getData() async {
    Uri url2uri = Uri.parse(
        'https://api.openrouteservice.org/geocode/autocomplete?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&text=$place');

    http.Response response = await http.get(url2uri);

    print(
        'https://api.openrouteservice.org/geocode/autocomplete?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&text=$place');

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

class MyLocationFromLatLng {
  final String apiKey =
      '5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab';
  final double lat;
  final double lng;

  MyLocationFromLatLng({
    required this.lat,
    required this.lng,
  });


  Future getData() async {
    Uri url2uri = Uri.parse(
        'https://api.openrouteservice.org/geocode/reverse?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&point.lon=$lng&point.lat=$lat');

    http.Response response = await http.get(url2uri);

    print(
        'https://api.openrouteservice.org/geocode/reverse?api_key=5b3ce3597851110001cf6248e53dd3e2df674e4d839007f2e5bfa9ab&point.lon=$lng&point.lat=$lat');

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

