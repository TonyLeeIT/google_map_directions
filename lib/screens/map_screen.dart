import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repo/directions_repository.dart';
import 'package:geolocator/geolocator.dart';

import '../service/geolocator_service.dart';

class MapScreen extends StatefulWidget {
  final Position initialPosition;

  MapScreen({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(21.0322262, 105.7888827), zoom: 11.5);
  final GeolocatorService geoService = GeolocatorService();
  late GoogleMapController _googleMapController;
  var _origin;
  var _destination;
  var _info;

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          "Google Map",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: _origin.position, zoom: 14.5, tilt: 50.0))),
              style: TextButton.styleFrom(
                  primary: Colors.redAccent,
                  textStyle: TextStyle(fontWeight: FontWeight.w600)),
              child: Text("ORIGIN"),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: _destination.position, zoom: 14.5, tilt: 50.0))),
              style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: TextStyle(fontWeight: FontWeight.w600)),
              child: Text("DESTINATION"),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialPosition.latitude,
                    widget.initialPosition.longitude),
                zoom: 11.5),
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              // Marker(
              //     markerId: MarkerId("Me"),
              //     infoWindow: InfoWindow(title: "Me"),
              //     icon: BitmapDescriptor.defaultMarkerWithHue(
              //         BitmapDescriptor.hueViolet),
              //     position: LatLng(widget.initialPosition.latitude,
              //         widget.initialPosition.longitude)),
              if (_origin != null) _origin,
              if (_destination != null) _destination
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ),
          Positioned(
              top: 544.0,
              right: 20.0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _googleMapController.animateCamera(
                        _info != null
                            ? CameraUpdate.newLatLngBounds(_info.bounds, 1000.0)
                            : CameraUpdate.newCameraPosition(CameraPosition(
                                target: LatLng(widget.initialPosition.latitude,
                                    widget.initialPosition.longitude),
                                zoom: 11.5))),
                    child: Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Icon(Icons.home)),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  GestureDetector(
                    onTap: () => _googleMapController.animateCamera(
                        _info != null
                            ? CameraUpdate.newLatLngBounds(_info.bounds, 1000.0)
                            : CameraUpdate.newCameraPosition(CameraPosition(
                                target: LatLng(widget.initialPosition.latitude,
                                    widget.initialPosition.longitude),
                                zoom: 18.0))),
                    child: Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Icon(Icons.home)),
                  )
                ],
              )),

          //direction
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.small(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   foregroundColor: Colors.black,
      //   onPressed: () => _googleMapController.animateCamera(_info != null
      //       ? CameraUpdate.newLatLngBounds(_info.bounds, 1000.0)
      //       : CameraUpdate.newCameraPosition(CameraPosition(
      //           target: LatLng(widget.initialPosition.latitude,
      //               widget.initialPosition.longitude),
      //           zoom: 11.5))),
      //   child: const Icon(Icons.center_focus_strong),
      // ),
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: MarkerId("origin"),
            infoWindow: InfoWindow(title: "Origin"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: pos);
        _destination = null;
      });

      // Reset info
      _info = null;
    } else {
      setState(() {
        _destination = Marker(
            markerId: MarkerId("destination"),
            infoWindow: InfoWindow(title: "Destination"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
      });
      print("get directions");
      // Get directions
      final directionsRepository = new DirectionsRepository();

      final directions = await directionsRepository.getDirections(
          origin: _origin.position, destination: pos);
      setState(() => _info = directions!);
      print("direction : ${_info}");
    }
  }

  Future<void> centerScreen(Position position) async {
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15)));
  }
}
