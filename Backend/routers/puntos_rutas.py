from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.punto_ruta import PuntoRutaCreate, PuntoRutaPublic, PuntoRutaUpdate
from controller.PuntoRuta import (
    LeerPuntosRuta, CrearPuntoRuta, LeerPuntoRutaPorId, ActualizarPuntoRuta, EliminarPuntoRuta
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/puntosruta/", response_model=list[PuntoRutaPublic])
def Obtener_Puntos_Ruta(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 10000000000,

):
    return LeerPuntosRuta(session, offset=offset, limit=limit)

@router.post("/puntosruta/", response_model=PuntoRutaPublic)
def Agregar_Punto_Ruta(
    punto: PuntoRutaCreate,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return CrearPuntoRuta(punto, session)

@router.get("/puntosruta/{id}", response_model=PuntoRutaPublic)
def Obtener_Punto_Ruta_Por_Id(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerPuntoRutaPorId(id, session)

@router.patch("/puntosruta/{id}", response_model=PuntoRutaPublic)
def Actualizar_Punto_Ruta(
    id: int,
    datos: PuntoRutaUpdate,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return ActualizarPuntoRuta(id, datos, session)

@router.delete("/puntosruta/{id}")
def Eliminar_Punto_Ruta(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return EliminarPuntoRuta(id, session)
