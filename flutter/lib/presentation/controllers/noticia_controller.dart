import 'dart:io';
import 'package:get/get.dart';
import '../../data/models/noticia.dart';
import '../../data/services/noticia_service.dart';

class NoticiaController extends GetxController {
  final NoticiaService _noticiaService = NoticiaService();
  
  var noticias = <Noticia>[].obs;
  var noticiasRecientes = <Noticia>[].obs;
  var isLoading = false.obs;
  var selectedNoticia = Noticia(
    idNoticia: 0,
    nombre: '',
    descripcion: '',
    imagen: '',
    fechaPublicacion: DateTime.now(),
  ).obs;

  @override
  void onInit() {
    fetchNoticias();
    fetchNoticiasRecientes();
    super.onInit();
  }

  Future<void> fetchNoticias() async {
    try {
      isLoading(true);
      final result = await _noticiaService.getNoticias();
      noticias.assignAll(result);
    } catch (e) {
      print('Error cargando noticias: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchNoticiasRecientes() async {
    try {
      final result = await _noticiaService.getNoticiasRecientes();
      noticiasRecientes.assignAll(result);
    } catch (e) {
      print('Error cargando noticias recientes: $e');
    }
  }

  Future<void> fetchNoticiaById(int id) async {
    try {
      isLoading(true);
      final noticia = await _noticiaService.getNoticiaById(id);
      selectedNoticia(noticia);
    } catch (e) {
      print('Error cargando noticia: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 CREAR NOTICIA - NUEVO MÉTODO CORREGIDO
  Future<void> createNoticia({
    required String nombre,
    required String descripcion,
    required File imagen,
  }) async {
    try {
      isLoading(true);
      final nuevaNoticia = await _noticiaService.createNoticia(
        nombre: nombre,
        descripcion: descripcion,
        imagen: imagen,
      );
      
      // Agregar la nueva noticia a la lista
      noticias.insert(0, nuevaNoticia);
      await fetchNoticiasRecientes(); // Actualizar recientes también
      
    } catch (e) {
      print('Error creando noticia: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 ACTUALIZAR NOTICIA - NUEVO MÉTODO CORREGIDO
  Future<void> updateNoticia({
    required int id,
    String? nombre,
    String? descripcion,
    File? imagen,
  }) async {
    try {
      isLoading(true);
      final noticiaActualizada = await _noticiaService.updateNoticia(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        imagen: imagen,
      );
      
      // Actualizar en la lista
      final index = noticias.indexWhere((n) => n.idNoticia == id);
      if (index != -1) {
        noticias[index] = noticiaActualizada;
      }
      
      await fetchNoticiasRecientes(); // Actualizar recientes también
      
    } catch (e) {
      print('Error actualizando noticia: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteNoticia(int id) async {
    try {
      isLoading(true);
      await _noticiaService.deleteNoticia(id);
      noticias.removeWhere((noticia) => noticia.idNoticia == id);
      await fetchNoticiasRecientes(); // Actualizar recientes también
    } catch (e) {
      print('Error eliminando noticia: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // 🔹 Buscar noticias por título
  List<Noticia> searchNoticias(String query) {
    if (query.isEmpty) return noticias;
    return noticias.where((noticia) {
      return noticia.nombre.toLowerCase().contains(query.toLowerCase()) ||
             noticia.descripcion.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // 🔹 Obtener noticias del último mes
  List<Noticia> get noticiasDelMes {
    final haceUnMes = DateTime.now().subtract(const Duration(days: 30));
    return noticias.where((noticia) => 
      noticia.fechaPublicacion.isAfter(haceUnMes)
    ).toList();
  }
}