from fastapi import APIRouter, Depends
from sqlmodel import Session, select, func
from config.database import get_session
from models.usuario import Usuario

router = APIRouter(prefix="/admin/debug", tags=["admin-debug"])

@router.get("/usuarios-fechas")
async def debug_usuarios_fechas(session: Session = Depends(get_session)):
    """Diagnóstico de usuarios y fechas"""
    try:
        # Total de usuarios
        total_usuarios = session.exec(select(func.count(Usuario.IdUsuario))).first() or 0
        
        # Usuarios con sus fechas
        usuarios = session.exec(select(Usuario)).all()
        
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
            "diagnostico": {
                "hay_usuarios": total_usuarios > 0,
                "total_registros": len(usuarios)
            }
        }
    except Exception as e:
        return {"error": str(e)}

@router.get("/database-structure")
async def debug_database_structure(session: Session = Depends(get_session)):
    """Diagnóstico de la estructura de la base de datos"""
    try:
        # Verificar datos reales
        usuarios_raw = session.exec(select(Usuario)).limit(5).all()
        
        return {
            "estructura_ejemplo": {
                "campos_disponibles": ["IdUsuario", "Nombre", "Apellido", "Correo", "FechaRegistro", "estado"] if usuarios_raw else [],
                "total_usuarios": len(usuarios_raw)
            },
            "datos_brutos": [
                {
                    "IdUsuario": u.IdUsuario,
                    "Nombre": u.Nombre,
                    "Apellido": u.Apellido,
                    "Correo": u.Correo,
                    "FechaRegistro": u.FechaRegistro.isoformat() if u.FechaRegistro else None,
                    "estado": u.estado
                } for u in usuarios_raw
            ]
        }
    except Exception as e:
        return {"error": str(e)}