from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, func, select
from config.database import get_session
from models.usuario import Usuario
from models.bus import Bus
from models.bus_favorito import BusFavorito
from models.lugar_favorito import LugarFavorito

# Crear router para estadísticas administrativas
router = APIRouter(prefix="/admin/estadisticas", tags=["admin-estadisticas"])

@router.get("/general")
async def obtener_estadisticas_generales(session: Session = Depends(get_session)):
    """Estadísticas generales del sistema"""
    try:
        total_buses_favoritos = session.exec(select(func.count(BusFavorito.IdBusFavorito))).first() or 0
        total_lugares_favoritos = session.exec(select(func.count(LugarFavorito.Id))).first() or 0
        total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first() or 0
        
        return {
            "total_usuarios": total_usuarios,
            "total_buses_favoritos": total_buses_favoritos,
            "total_lugares_favoritos": total_lugares_favoritos
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener estadísticas: {str(e)}")

@router.get("/buses-favoritos")
async def obtener_estadisticas_buses_favoritos(session: Session = Depends(get_session)):
    """Obtiene los buses más marcados como favoritos"""
    try:
        query = (
            select(BusFavorito.IdBus, func.count(BusFavorito.IdBus).label("total_favoritos"))
            .group_by(BusFavorito.IdBus)
            .order_by(func.count(BusFavorito.IdBus).desc())
            .limit(10)
        )
        resultados = session.exec(query).all()
        
        buses_favoritos = []
        for id_bus, total in resultados:
            bus = session.get(Bus, id_bus)
            if bus:
                buses_favoritos.append({
                    "id_bus": id_bus,
                    "numero": getattr(bus, 'NumeroBus', getattr(bus, 'numero', 'N/A')),
                    "placa": getattr(bus, 'Placa', getattr(bus, 'placa', 'N/A')),
                    "modelo": getattr(bus, 'Modelo', getattr(bus, 'modelo', 'N/A')),
                    "marca": getattr(bus, 'Marca', getattr(bus, 'marca', 'N/A')),
                    "total_favoritos": total
                })
        
        return {"buses_favoritos": buses_favoritos}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener buses favoritos: {str(e)}")

@router.get("/lugares-favoritos")
async def obtener_estadisticas_lugares_favoritos(session: Session = Depends(get_session)):
    """Obtiene estadísticas de lugares favoritos"""
    try:
        total_lugares = session.exec(select(func.count(LugarFavorito.Id))).first() or 0
        
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener lugares favoritos: {str(e)}")

@router.get("/usuarios-por-fecha")
async def obtener_estadisticas_usuarios_por_fecha(
    dias: int = 0,
    session: Session = Depends(get_session)
):
    """Obtiene estadísticas de usuarios registrados por fecha"""
    try:
        print(f"📅 Solicitando estadísticas para {dias} días")
        
        # Consulta base
        query_base = select(
            Usuario.FechaRegistro,
            func.count(Usuario.IdUsuario).label("total_usuarios")
        )
        
        # Aplicar filtro si es necesario
        if dias > 0:
            fecha_inicio = datetime.now().date() - timedelta(days=dias)
            query_base = query_base.where(Usuario.FechaRegistro >= fecha_inicio)
        
        # Ejecutar consulta
        query_final = query_base.group_by(Usuario.FechaRegistro).order_by(Usuario.FechaRegistro)
        resultados = session.exec(query_final).all()
        
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
        
        return {
            "usuarios_por_fecha": usuarios_por_fecha,
            "estadisticas_generales": {
                "total_usuarios": total_usuarios,
                "usuarios_activos": usuarios_activos,
                "usuarios_inactivos": total_usuarios - usuarios_activos
            },
            "periodo": {
                "dias": dias,
                "fecha_inicio": fecha_inicio.isoformat() if dias > 0 else "Todo el historial",
                "total_en_periodo": len(usuarios_por_fecha)
            }
        }
        
    except Exception as e:
        print(f"❌ Error en usuarios-por-fecha: {e}")
        raise HTTPException(status_code=500, detail=f"Error al obtener estadísticas: {str(e)}")

@router.get("/usuarios-fallback")
async def obtener_usuarios_fallback(session: Session = Depends(get_session)):
    """Endpoint de FALLBACK - siempre funciona"""
    try:
        # Consulta usando el modelo (más seguro)
        resultados = session.exec(
            select(Usuario.FechaRegistro, func.count(Usuario.IdUsuario))
            .group_by(Usuario.FechaRegistro)
            .order_by(Usuario.FechaRegistro)
        ).all()
        
        # Formatear resultados
        usuarios_por_fecha = []
        for fecha, total in resultados:
            usuarios_por_fecha.append({
                "fecha": fecha.isoformat() if fecha else None,
                "fecha_formateada": fecha.strftime("%d/%m/%Y") if fecha else "N/A",
                "total_usuarios": total
            })
        
        # Estadísticas generales
        total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first() or 0
        usuarios_activos = session.exec(select(func.count(Usuario.IdUsuario)).where(Usuario.estado == True)).first() or 0
        
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
            "fuente": "fallback_model_query"
        }
        
    except Exception as e:
        return {
            "usuarios_por_fecha": [],
            "estadisticas_generales": {
                "total_usuarios": 0,
                "usuarios_activos": 0,
                "usuarios_inactivos": 0
            },
            "error": f"Fallback error: {str(e)}"
        }