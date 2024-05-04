
import "dart:async";


import"package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:location/location.dart";
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import "const.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location locationController=  Location();
  final Completer<GoogleMapController> gMapController=
  Completer<GoogleMapController>();

  static const LatLng uttara= LatLng(23.8759,90.3795);
  static const LatLng dhanmondi= LatLng(23.7461, 90.3742);
  LatLng? currentLoc= null;
  Map<PolylineId, Polyline> polylines={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates().then((_) =>{
      getPolyLinePoints().then((coordinates) => {
        generatePolyLineFromPoin(coordinates),
      }),
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text('Real Time Location'),
        centerTitle: true,
      ),
      body:currentLoc==null?
      const Center(child: Text('Loading'),
      )
          : GoogleMap(
        onMapCreated: ((GoogleMapController controller)=>
          gMapController.complete(controller)),
        initialCameraPosition:CameraPosition(
            target: uttara,
        zoom: 16        ),
      markers: {
        Marker(markerId: MarkerId("currentLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: currentLoc!,
        ),
          Marker(markerId: MarkerId("sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
            position: uttara,
          ),
        Marker(markerId: MarkerId("destinationLocation"),
              icon: BitmapDescriptor.defaultMarker,
            position: dhanmondi,
          )
        },
        polylines:Set<Polyline>.of(polylines.values) ,

      ),

    );
  }
  Future<void> cameraToPosition(LatLng pos) async{
    final GoogleMapController controller= await gMapController.future;
    CameraPosition newCameraPosition=CameraPosition(target: pos,zoom: 13,);
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition),);
  }
  Future<void> getLocationUpdates () async{
     bool serviceEnabled;
     PermissionStatus permissionGranted;
     serviceEnabled=await locationController.serviceEnabled();
     if(serviceEnabled){
       serviceEnabled= await locationController.requestService();
     }else{
       return;
     }
     permissionGranted=await locationController.hasPermission();
     if(permissionGranted==PermissionStatus.denied){
       permissionGranted=await locationController.requestPermission();
       if(permissionGranted!=PermissionStatus.granted){
         return;
     }

     }
     locationController.onLocationChanged.listen((LocationData currentLocation) {
       if(currentLocation.latitude!=null && currentLocation.longitude!=null){
         setState(() {
           currentLoc= LatLng(currentLocation.latitude!, currentLocation.longitude!);
            cameraToPosition(currentLoc!);
         });
       }
     });
  }
  Future<List<LatLng>>getPolyLinePoints() async{
    List<LatLng> polyLineCoordinates=[];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAPS_API_KEY,
        PointLatLng(uttara.latitude, uttara.longitude),
        PointLatLng(dhanmondi.latitude, dhanmondi.longitude),
        travelMode: TravelMode.driving,
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) { 
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }else{
      print(result.errorMessage);
    }
    return polyLineCoordinates;

  }
  void generatePolyLineFromPoin(List<LatLng> polyLineCoordinates)async{
    PolylineId id=PolylineId("poly");
    Polyline polyline=Polyline(
        polylineId:id,
        color: Colors.black,
        points: polyLineCoordinates,
        width: 8
     );
    setState(() {
      polylines[id]=polyline;
    });
  }
}
