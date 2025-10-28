import sys
import os

from datetime import datetime, timedelta  
from fastapi.params import Depends
from sqlmodel import Session, func, select
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
sys.path.append(os.path.join(os.path.dirname(__file__), 'models'))


from fastapi import FastAPI
from contextlib import asynccontextmanager
from config.database import create_db_and_tables, get_session
from routers.usuarios import router as users_router
from routers.auth import router as auth_router 

from routers.buses import router as buses_router
from routers.choferes import router as choferes_router
from routers.rutas import router as rutas_router
from routers.puntos_rutas import router as puntos_rutas_router 

from routers.paraderos import router as paraderos_router
from routers.lugares_cercanos import router as lugares_cercanos_router
from routers.noticias import router as noticias_router
from routers.buses_favoritos import router as buses_favoritos_router
from routers.lugares_favoritos import router as lugares_favoritos_router

from routers.simulacion import router as simulacion_router

from models.bus_favorito import BusFavorito
from models.lugar_favorito import LugarFavorito
from models.bus import Bus
from models.usuario import Usuario

app = FastAPI()

# 🔥 NUEVO: Servir archivos estáticos
app.mount("/static", StaticFiles(directory="static"), name="static")

# 🔥 NUEVO: Ruta para la página admin
@app.get("/admin")
async def admin_page():
    return FileResponse("static/admin.html")

# 🔥 NUEVOS ENDPOINTS PARA ESTADÍSTICAS
@app.get("/api/admin/estadisticas/buses-favoritos")
async def obtener_estadisticas_buses_favoritos(session: Session = Depends(get_session)):
    """Obtiene los buses más marcados como favoritos"""
    query = (
        select(BusFavorito.IdBus, func.count(BusFavorito.IdBus).label("total_favoritos"))
        .group_by(BusFavorito.IdBus)
        .order_by(func.count(BusFavorito.IdBus).desc())
        .limit(10)
    )
    resultados = session.exec(query).all()
    
    # Obtener detalles de los buses
    buses_favoritos = []
    for id_bus, total in resultados:
        bus = session.get(Bus, id_bus)
        if bus:
            buses_favoritos.append({
                "id_bus": id_bus,
                "numero_bus": getattr(bus, 'NumeroBus', 'N/A'),
                "placa": getattr(bus, 'Placa', 'N/A'),
                "total_favoritos": total
            })
    
    return {"buses_favoritos": buses_favoritos}

@app.get("/api/admin/buses/{bus_id}")
async def obtener_datos_bus(bus_id: int, session: Session = Depends(get_session)):
    """Endpoint temporal para obtener datos de un bus específico"""
    bus = session.get(Bus, bus_id)
    if not bus:
        return {"error": "Bus no encontrado"}
    
    return {
        "id": bus.IdBus,
        "numero": bus.numero,
        "placa": bus.placa,
        "modelo": bus.modelo,
        "marca": bus.marca
    }

@app.get("/api/admin/estadisticas/lugares-favoritos")
async def obtener_estadisticas_lugares_favoritos(session: Session = Depends(get_session)):
    """Obtiene estadísticas de lugares favoritos"""
    # Total de lugares favoritos registrados
    total_lugares = session.exec(select(func.count(LugarFavorito.Id))).first()
    
    # Lugares favoritos más populares (por nombre)
    query_lugares = (
        select(LugarFavorito.Nombre, func.count(LugarFavorito.Nombre).label("total"))
        .group_by(LugarFavorito.Nombre)
        .order_by(func.count(LugarFavorito.Nombre).desc())
        .limit(10)
    )
    lugares_populares = session.exec(query_lugares).all()
    
    return {
        "total_lugares": total_lugares,
        "lugares_populares": [
            {"nombre": nombre, "total": total} 
            for nombre, total in lugares_populares
        ]
    }

@app.get("/api/admin/estadisticas/general")
async def obtener_estadisticas_generales(session: Session = Depends(get_session)):
    """Estadísticas generales del sistema"""
    total_buses_favoritos = session.exec(select(func.count(BusFavorito.IdBusFavorito))).first()
    total_lugares_favoritos = session.exec(select(func.count(LugarFavorito.Id))).first()
    total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first()
    
    return {
        "total_usuarios": total_usuarios,
        "total_buses_favoritos": total_buses_favoritos,
        "total_lugares_favoritos": total_lugares_favoritos
    }

# 🔥 ENDPOINTS CORREGIDOS - USANDO NOMBRES EXACTOS DE BD
@app.get("/api/admin/estadisticas/usuarios-por-fecha")
async def obtener_estadisticas_usuarios_por_fecha(
    session: Session = Depends(get_session),
    dias: int = 0
):
    """Obtiene estadísticas de usuarios registrados por fecha - CORREGIDO"""
    try:
        print(f"📅 Solicitando estadísticas para {dias} días")
        
        # Consulta BASE usando nombres exactos de BD
        query_base = select(
            Usuario.FechaRegistro,
            func.count(Usuario.IdUsuario).label("total_usuarios")
        )
        
        # Aplicar filtro si es necesario
        if dias > 0:
            fecha_inicio = datetime.now().date() - timedelta(days=dias)
            query_base = query_base.where(Usuario.FechaRegistro >= fecha_inicio)
            print(f"🔍 Filtro aplicado: desde {fecha_inicio}")
        else:
            print("🔍 Sin filtro: todo el historial")
        
        # Ejecutar consulta
        query_final = query_base.group_by(Usuario.FechaRegistro).order_by(Usuario.FechaRegistro)
        resultados = session.exec(query_final).all()
        
        print(f"📊 Resultados encontrados: {len(resultados)}")
        
        # Formatear resultados
        usuarios_por_fecha = []
        for fecha, total in resultados:
            usuarios_por_fecha.append({
                "fecha": fecha.isoformat(),
                "fecha_formateada": fecha.strftime("%d/%m/%Y"),
                "total_usuarios": total
            })
        
        # Obtener estadísticas generales
        total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first() or 0
        usuarios_activos = session.exec(select(func.count(Usuario.IdUsuario)).where(Usuario.estado == True)).first() or 0
        usuarios_inactivos = session.exec(select(func.count(Usuario.IdUsuario)).where(Usuario.estado == False)).first() or 0
        
        response_data = {
            "usuarios_por_fecha": usuarios_por_fecha,
            "estadisticas_generales": {
                "total_usuarios": total_usuarios,
                "usuarios_activos": usuarios_activos,
                "usuarios_inactivos": usuarios_inactivos
            },
            "periodo": {
                "dias": dias,
                "fecha_inicio": fecha_inicio.isoformat() if dias > 0 else "Todo el historial",
                "total_en_periodo": len(usuarios_por_fecha)
            }
        }
        
        print(f"✅ Respuesta: {total_usuarios} usuarios totales")
        return response_data
        
    except Exception as e:
        print(f"❌ Error crítico: {e}")
        import traceback
        traceback.print_exc()
        
        return {
            "usuarios_por_fecha": [],
            "estadisticas_generales": {
                "total_usuarios": 0,
                "usuarios_activos": 0,
                "usuarios_inactivos": 0
            },
            "periodo": {
                "dias": dias,
                "fecha_inicio": "Error",
                "total_en_periodo": 0
            },
            "error": str(e)
        }

@app.get("/api/admin/debug/usuarios-fechas")
async def debug_usuarios_fechas(session: Session = Depends(get_session)):
    """Diagnóstico CORREGIDO - usando consultas directas"""
    try:
        # 1. Consulta directa para diagnosticar
        query_directa = "SELECT IdUsuario, Nombre, Apellido, FechaRegistro, estado FROM usuario"
        usuarios_raw = session.exec(query_directa).fetchall()
        
        # 2. Consulta agrupada por fecha
        query_agrupada = """
        SELECT FechaRegistro, COUNT(IdUsuario) as total 
        FROM usuario 
        GROUP BY FechaRegistro 
        ORDER BY FechaRegistro
        """
        fechas_agrupadas = session.exec(query_agrupada).fetchall()
        
        # 3. Consulta con filtro de 7 días
        fecha_7_dias = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
        query_filtrada = f"""
        SELECT FechaRegistro, COUNT(IdUsuario) as total 
        FROM usuario 
        WHERE FechaRegistro >= '{fecha_7_dias}'
        GROUP BY FechaRegistro 
        ORDER BY FechaRegistro
        """
        fechas_filtradas = session.exec(query_filtrada).fetchall()
        
        return {
            "total_usuarios": len(usuarios_raw),
            "usuarios_registrados": [
                {
                    "id": u[0],
                    "nombre": f"{u[1]} {u[2]}",
                    "fecha_registro": u[3].isoformat() if u[3] else None,
                    "estado": bool(u[4])
                } for u in usuarios_raw
            ],
            "agrupado_sin_filtro": [
                {"fecha": f[0].isoformat(), "total": f[1]} for f in fechas_agrupadas
            ],
            "agrupado_7_dias": [
                {"fecha": f[0].isoformat(), "total": f[1]} for f in fechas_filtradas
            ],
            "diagnostico": {
                "hay_usuarios": len(usuarios_raw) > 0,
                "hay_fechas_sin_filtro": len(fechas_agrupadas) > 0,
                "hay_fechas_con_filtro": len(fechas_filtradas) > 0,
                "estructura_correcta": True
            }
        }
    except Exception as e:
        return {"error": str(e), "diagnostico": {"estructura_correcta": False}}

@app.get("/api/admin/debug/database-structure")
async def debug_database_structure(session: Session = Depends(get_session)):
    """Diagnóstico de estructura CORREGIDO"""
    try:
        # Consulta directa para ver estructura
        result = session.exec("SELECT * FROM usuario LIMIT 1").first()
        
        # Consulta para ver todos los usuarios
        todos_usuarios = session.exec("SELECT * FROM usuario").fetchall()
        
        return {
            "estructura_ejemplo": dict(result._mapping) if result else "No hay datos",
            "total_usuarios": len(todos_usuarios),
            "columnas_disponibles": list(result._mapping.keys()) if result else [],
            "datos_completos": [
                dict(usuario._mapping) for usuario in todos_usuarios
            ]
        }
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/api/admin/debug/usuarios-fechas")
async def debug_usuarios_fechas(session: Session = Depends(get_session)):
    """Diagnóstico completo de usuarios y fechas"""
    try:
        # 1. Total de usuarios
        total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first() or 0
        
        # 2. Usuarios con sus fechas
        usuarios = session.exec(select(Usuario)).all()
        
        # 3. Agrupado por fecha (sin filtro)
        query_sin_filtro = (
            select(
                Usuario.FechaRegistro,
                func.count(Usuario.IdUsuario).label("total")
            )
            .group_by(Usuario.FechaRegistro)
            .order_by(Usuario.FechaRegistro)
        )
        fechas_sin_filtro = session.exec(query_sin_filtro).all()
        
        # 4. Agrupado por fecha (con filtro de 7 días)
        fecha_7_dias = datetime.now().date() - timedelta(days=7)
        query_con_filtro = (
            select(
                Usuario.FechaRegistro,
                func.count(Usuario.IdUsuario).label("total")
            )
            .where(Usuario.FechaRegistro >= fecha_7_dias)
            .group_by(Usuario.FechaRegistro)
            .order_by(Usuario.FechaRegistro)
        )
        fechas_con_filtro = session.exec(query_con_filtro).all()
        
        return {
            "total_usuarios": total_usuarios,
            "usuarios_registrados": [
                {
                    "id": u.IdUsuario,
                    "nombre": f"{u.Nombre} {u.Apellido}",
                    "fecha_registro": u.FechaRegistro.isoformat() if u.FechaRegistro else None,
                    "estado": u.estado
                } for u in usuarios
            ],
            "agrupado_sin_filtro": [
                {"fecha": f.isoformat(), "total": t} for f, t in fechas_sin_filtro
            ],
            "agrupado_7_dias": [
                {"fecha": f.isoformat(), "total": t} for f, t in fechas_con_filtro
            ],
            "filtro_7_dias_desde": fecha_7_dias.isoformat(),
            "diagnostico": {
                "hay_usuarios": total_usuarios > 0,
                "hay_fechas_sin_filtro": len(fechas_sin_filtro) > 0,
                "hay_fechas_con_filtro": len(fechas_con_filtro) > 0
            }
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/admin/debug/database-structure")
async def debug_database_structure(session: Session = Depends(get_session)):
    """Diagnóstico de la estructura de la base de datos"""
    try:
        # Verificar estructura de la tabla usuario
        result = session.exec("PRAGMA table_info(usuario)").all()
        
        # Verificar datos reales
        usuarios_raw = session.exec("SELECT * FROM usuario LIMIT 5").all()
        
        return {
            "estructura_tabla_usuario": [
                {"column_name": col[1], "type": col[2], "notnull": col[3], "pk": col[5]} 
                for col in result
            ],
            "datos_brutos": usuarios_raw,
            "total_usuarios": len(usuarios_raw)
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/admin/estadisticas/usuarios-fallback")
async def obtener_usuarios_fallback(session: Session = Depends(get_session)):
    """Endpoint de FALLBACK - siempre funciona"""
    try:
        # Consulta SQL directa - sin depender de modelos
        query = """
        SELECT 
            FechaRegistro,
            COUNT(IdUsuario) as total_usuarios
        FROM usuario 
        GROUP BY FechaRegistro 
        ORDER BY FechaRegistro
        """
        
        resultados = session.exec(query).fetchall()
        
        # Formatear resultados
        usuarios_por_fecha = []
        for fecha, total in resultados:
            usuarios_por_fecha.append({
                "fecha": fecha.isoformat(),
                "fecha_formateada": fecha.strftime("%d/%m/%Y"),
                "total_usuarios": total
            })
        
        # Estadísticas generales
        count_query = "SELECT COUNT(IdUsuario) FROM usuario"
        total_usuarios = session.exec(count_query).first()[0]
        
        active_query = "SELECT COUNT(IdUsuario) FROM usuario WHERE estado = 1"
        usuarios_activos = session.exec(active_query).first()[0]
        
        return {
            "usuarios_por_fecha": usuarios_por_fecha,
            "estadisticas_generales": {
                "total_usuarios": total_usuarios,
                "usuarios_activos": usuarios_activos,
                "usuarios_inactivos": total_usuarios - usuarios_activos
            },
            "periodo": {
                "dias": 0,
                "fecha_inicio": "Todo el historial",
                "total_en_periodo": len(usuarios_por_fecha)
            },
            "fuente": "fallback_direct_sql"
        }
        
    except Exception as e:
        return {
            "usuarios_por_fecha": [],
            "estadisticas_generales": {
                "total_usuarios": 0,
                "usuarios_activos": 0,
                "usuarios_inactivos": 0
            },
            "error": f"Fallback también falló: {str(e)}"
        }
    
app.include_router(simulacion_router, prefix="/api", tags=["simulacion"])

app.include_router(auth_router, tags=["authentication"])
app.include_router(users_router, prefix="/api", tags=["usuarios"])
app.include_router(buses_router, prefix="/api", tags=["buses"])
app.include_router(choferes_router, prefix="/api", tags=["choferes"])
app.include_router(rutas_router, prefix="/api", tags=["rutas"])
app.include_router(puntos_rutas_router, prefix="/api", tags=["puntos_rutas"])

app.include_router(paraderos_router, prefix="/api", tags=["paraderos"])
app.include_router(lugares_cercanos_router, prefix="/api", tags=["lugares_cercanos"])
app.include_router(noticias_router, prefix="/api", tags=["noticias"])
app.include_router(buses_favoritos_router, prefix="/api", tags=["buses_favoritos"])
app.include_router(lugares_favoritos_router, prefix="/api", tags=["lugares_favoritos"])


@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/")
def read_root():
    return {"message": "API funcionando"} 