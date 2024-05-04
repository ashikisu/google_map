import"package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng mohakhali= LatLng(23.7778,90.4057);
  static const LatLng dhanmondi= LatLng(23.7461, 90.3742);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text('Real Time Location'),
        centerTitle: true,
      ),
      body:GoogleMap(
        initialCameraPosition:CameraPosition(
            target: mohakhali,
        zoom: 16        ),
      markers: {
          Marker(markerId: MarkerId(" currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
            position: mohakhali,
          ),
        Marker(markerId: MarkerId("sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
            position: dhanmondi,
          )
        }

      ),

    );
  }
}
