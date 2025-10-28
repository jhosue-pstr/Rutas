from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.lugar_favorito import LugarFavoritoCreate, LugarFavoritoPublic, LugarFavoritoUpdate
from controller.LugarFavorito import (
    LeerLugaresFavoritos, CrearLugarFavorito, LeerLugarFavoritoPorId, 
    ActualizarLugarFavorito, EliminarLugarFavorito, LeerLugaresFavoritosPorUsuario
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/lugares_favoritos/", response_model=list[LugarFavoritoPublic])
def Obtener_Lugares_Favoritos(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerLugaresFavoritos(session, offset=offset, limit=limit)

@router.get("/usuarios/{usuario_id}/lugares_favoritos/", response_model=list[LugarFavoritoPublic])
def Obtener_Lugares_Favoritos_Por_Usuario(
    usuario_id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerLugaresFavoritosPorUsuario(usuario_id, session)

@router.post("/lugares_favoritos/", response_model=LugarFavoritoPublic)
def Agregar_Lugar_Favorito(
    lugar: LugarFavoritoCreate,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return CrearLugarFavorito(lugar, session)

@router.get("/lugares_favoritos/{id}", response_model=LugarFavoritoPublic)
def Obtener_Lugar_Favorito_Por_Id(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return LeerLugarFavoritoPorId(id, session)

@router.patch("/lugares_favoritos/{id}", response_model=LugarFavoritoPublic)
def Actualizar_Lugar_Favorito(
    id: int,
    datos: LugarFavoritoUpdate,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return ActualizarLugarFavorito(id, datos, session)

@router.delete("/lugares_favoritos/{id}")
def Eliminar_Lugar_Favorito(
    id: int,
    session: Session = Depends(get_session),
        current_user: Usuario = Depends(get_current_active_user)

):
    return EliminarLugarFavorito(id, session)