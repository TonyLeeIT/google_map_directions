import 'package:flutter/material.dart';
import './screens/map_screen.dart';
import 'package:provider/provider.dart';
import './service/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final geoService = GeolocatorService();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => geoService.getInitialLocation(),
      child: MaterialApp(
        title: "Google Map",
        theme: ThemeData(primaryColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? MapScreen(initialPosition: position)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
