import 'dart:io';
import 'package:get/get.dart';
import '../../data/models/chofer.dart';
import '../../data/services/chofer_service.dart';

class ChoferController extends GetxController {
  final ChoferService _choferService = ChoferService();
  
  var choferes = <Chofer>[].obs;
  var isLoading = false.obs;
  var selectedChofer = Chofer(
    idChofer: 0,
    nombre: '',
    fechaIngreso: DateTime.now(),
    estado: true,
  ).obs;

  @override
  void onInit() {
    fetchChoferes();
    super.onInit();
  }

  // 🔹 Obtener lista de choferes
  Future<void> fetchChoferes() async {
    try {
      isLoading(true);
      final result = await _choferService.getChoferes();
      choferes.assignAll(result);
    } catch (e) {
      print('Error cargando choferes: $e');
      // Puedes mostrar un snackbar aquí si lo prefieres
    } finally {
      isLoading(false);
    }
  }

  // 🔹 Obtener chofer por ID
  Future<void> fetchChoferById(int id) async {
    try {
      isLoading(true);
      final chofer = await _choferService.getChoferById(id);
      selectedChofer(chofer);
    } catch (e) {
      print('Error cargando chofer: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 CREAR CHOFER - NUEVO MÉTODO CORREGIDO
  Future<void> createChofer({
    required String nombre,
    String? apellido,
    String? dni,
    String? telefono,
    File? foto,
    File? qrPago,
    File? licenciaImg,
  }) async {
    try {
      isLoading(true);
      final nuevoChofer = await _choferService.createChofer(
        nombre: nombre,
        apellido: apellido,
        dni: dni,
        telefono: telefono,
        foto: foto,
        qrPago: qrPago,
        licenciaImg: licenciaImg,
      );
      
      // Agregar el nuevo chofer a la lista
      choferes.add(nuevoChofer);
      
    } catch (e) {
      print('Error creando chofer: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 ACTUALIZAR CHOFER - NUEVO MÉTODO CORREGIDO
  Future<void> updateChofer({
    required int id,
    String? nombre,
    String? apellido,
    String? dni,
    String? telefono,
    File? foto,
    File? qrPago,
    File? licenciaImg,
  }) async {
    try {
      isLoading(true);
      final choferActualizado = await _choferService.updateChofer(
        id: id,
        nombre: nombre,
        apellido: apellido,
        dni: dni,
        telefono: telefono,
        foto: foto,
        qrPago: qrPago,
        licenciaImg: licenciaImg,
      );
      
      // Actualizar en la lista
      final index = choferes.indexWhere((c) => c.idChofer == id);
      if (index != -1) {
        choferes[index] = choferActualizado;
      }
      
    } catch (e) {
      print('Error actualizando chofer: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 ELIMINAR CHOFER
  Future<void> deleteChofer(int id) async {
    try {
      isLoading(true);
      await _choferService.deleteChofer(id);
      choferes.removeWhere((chofer) => chofer.idChofer == id);
    } catch (e) {
      print('Error eliminando chofer: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 Buscar chofer por nombre
  List<Chofer> searchChoferes(String query) {
    if (query.isEmpty) return choferes;
    return choferes.where((chofer) {
      final nombreCompleto = '${chofer.nombre} ${chofer.apellido ?? ''}'.toLowerCase();
      return nombreCompleto.contains(query.toLowerCase()) ||
          (chofer.dni ?? '').contains(query);
    }).toList();
  }

  // 🔹 Obtener choferes activos
  List<Chofer> get choferesActivos {
    return choferes.where((chofer) => chofer.estado).toList();
  }

  // 🔹 Obtener choferes inactivos
  List<Chofer> get choferesInactivos {
    return choferes.where((chofer) => !chofer.estado).toList();
  }
}