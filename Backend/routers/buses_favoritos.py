from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.bus_favorito import BusFavoritoCreate, BusFavoritoPublic, BusFavoritoUpdate
from controller.BusFavorito import (
    LeerBusesFavoritos, CrearBusFavorito, LeerBusFavoritoPorId, 
    EliminarBusFavorito, LeerBusesFavoritosPorUsuario, EliminarBusFavoritoPorUsuarioYBuses
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/buses_favoritos/", response_model=list[BusFavoritoPublic])
def Obtener_Buses_Favoritos(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerBusesFavoritos(session, offset=offset, limit=limit)

@router.get("/usuarios/{usuario_id}/buses_favoritos/", response_model=list[BusFavoritoPublic])
def Obtener_Buses_Favoritos_Por_Usuario(
    usuario_id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerBusesFavoritosPorUsuario(usuario_id, session)

@router.post("/buses_favoritos/", response_model=BusFavoritoPublic)
def Agregar_Bus_Favorito(
    bus_favorito: BusFavoritoCreate,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return CrearBusFavorito(bus_favorito, session)

@router.get("/buses_favoritos/{id}", response_model=BusFavoritoPublic)
def Obtener_Bus_Favorito_Por_Id(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerBusFavoritoPorId(id, session)

@router.delete("/buses_favoritos/{id}")
def Eliminar_Bus_Favorito(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return EliminarBusFavorito(id, session)

@router.delete("/usuarios/{usuario_id}/buses_favoritos/{bus_id}")
def Eliminar_Bus_Favorito_Por_Usuario_Y_Bus(
    usuario_id: int,
    bus_id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return EliminarBusFavoritoPorUsuarioYBuses(usuario_id, bus_id, session)