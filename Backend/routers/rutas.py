from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.ruta import RutaCreate, RutaPublic, RutaUpdate
from controller.Ruta import (
    LeerRutas, CrearRuta, LeerRutaPorId, ActualizarRuta, EliminarRuta
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/rutas/", response_model=list[RutaPublic])
def Obtener_Rutas(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
    current_user: Usuario = Depends(get_current_active_user)
):
    return LeerRutas(session, offset=offset, limit=limit)

@router.post("/rutas/", response_model=RutaPublic)
def Agregar_Ruta(
    ruta: RutaCreate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return CrearRuta(ruta, session)

@router.get("/rutas/{id}", response_model=RutaPublic)
def Obtener_Ruta_Por_Id(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return LeerRutaPorId(id, session)

@router.patch("/rutas/{id}", response_model=RutaPublic)
def Actualizar_Ruta(
    id: int,
    datos: RutaUpdate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return ActualizarRuta(id, datos, session)

@router.delete("/rutas/{id}")
def Eliminar_Ruta(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return EliminarRuta(id, session)
