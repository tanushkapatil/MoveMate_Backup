import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusMapScreen extends StatelessWidget {
  final Map<String, dynamic> bus;
  final String source;
  final String destination;

  const BusMapScreen({
    Key? key,
    required this.bus,
    required this.source,
    required this.destination,
  }) : super(key: key);

  // Helper function to decode an encoded polyline string.
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    // Extract bus location
    final double busLat = bus['location']['lat'];
    final double busLng = bus['location']['lng'];

    // Create markers: one for the bus, and optionally for source/destination if desired.
    final markers = <Marker>{
      Marker(
        markerId: MarkerId(bus['busCode']),
        position: LatLng(busLat, busLng),
        infoWindow: InfoWindow(title: "Bus: ${bus['busCode']}"),
      ),
    };

    // Decode polyline if available.
    final polylinePoints = (bus['polyline'] != null && bus['polyline'].isNotEmpty)
        ? _decodePolyline(bus['polyline'])
        : <LatLng>[];

    final polylines = <Polyline>{};
    if (polylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route_${bus['busCode']}'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Route: ${bus['busCode']}"),
        backgroundColor: const Color(0xFF7F56D9),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(busLat, busLng),
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
      ),
    );
  }
}
