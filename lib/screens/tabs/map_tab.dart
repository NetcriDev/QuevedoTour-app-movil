import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../detail_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-1.0286, -79.4635), // Quevedo
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Build markers
        _markers.clear();
        for (var e in provider.allEstablishments) {
          _markers.add(
            Marker(
              markerId: MarkerId(e.id),
              position: LatLng(e.lat, e.lng),
              infoWindow: InfoWindow(
                title: e.name,
                snippet: e.categoryId, // Or category name lookup
                onTap: () {
                   Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => DetailScreen(establishment: e))
                      );
                },
              ),
            ),
          );
        }

        return Scaffold(
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
        );
      },
    );
  }
}
