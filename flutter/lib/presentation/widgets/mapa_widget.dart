import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaWidget extends StatefulWidget {
  final Function(LatLng)? onMapTap;
  final Function(LatLng)? onUbicacionObtenida;
  final Set<Marker>? markersExternos;
  final Set<Polyline>? polylinesExternos;
  final Set<Polyline>? rutasBuses; // ✅ NUEVO PARÁMETRO

  const MapaWidget({
    Key? key,
    this.onMapTap,
    this.onUbicacionObtenida,
    this.markersExternos,
    this.polylinesExternos,
    this.rutasBuses, // ✅ NUEVO
  }) : super(key: key);

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  GoogleMapController? _mapController;
  LatLng? _ubicacionActual;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _cargando = true);

    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      setState(() => _cargando = false);
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        setState(() => _cargando = false);
        return;
      }
    }

    try {
      Position posicion = await Geolocator.getCurrentPosition();
      setState(() {
        _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
        _cargando = false;
      });

      widget.onUbicacionObtenida?.call(_ubicacionActual!);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_ubicacionActual!, 15),
      );
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void _irAMiUbicacion() {
    if (_ubicacionActual != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_ubicacionActual!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
        ),
      );
    }

    if (_ubicacionActual == null) {
      return Center(child: Text('No se pudo obtener la ubicación'));
    }

    Set<Marker> markers = {};
    Set<Polyline> polylines = {};

    // Marcador de ubicación actual
    markers.add(
      Marker(
        markerId: MarkerId('ubicacion_actual'),
        position: _ubicacionActual!,
        infoWindow: InfoWindow(title: 'Mi ubicación'),
      ),
    );

    // Agregar marcadores externos
    if (widget.markersExternos != null) {
      markers.addAll(widget.markersExternos!);
    }

    // Agregar polylines externos (rutas de walking)
    if (widget.polylinesExternos != null) {
      polylines.addAll(widget.polylinesExternos!);
    }

    // ✅ AGREGAR RUTAS DE BUSES (si existen)
    if (widget.rutasBuses != null && widget.rutasBuses!.isNotEmpty) {
      polylines.addAll(widget.rutasBuses!);
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: _ubicacionActual!,
            zoom: 15,
          ),
          markers: markers,
          polylines: polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onTap: widget.onMapTap,
        ),

        // Botón de mi ubicación
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            heroTag: "btn_mapa_ubicacion",
            onPressed: _irAMiUbicacion,
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            mini: true,
            child: Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
