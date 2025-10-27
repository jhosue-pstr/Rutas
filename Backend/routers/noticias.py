from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.noticia import NoticiaCreate, NoticiaPublic, NoticiaUpdate
from controller.Noticia import (
    LeerNoticias, CrearNoticia, LeerNoticiaPorId, 
    ActualizarNoticia, EliminarNoticia, LeerNoticiasRecientes
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/noticias/", response_model=list[NoticiaPublic])
def Obtener_Noticias(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
):
    return LeerNoticias(session, offset=offset, limit=limit)

@router.get("/noticias/recientes/", response_model=list[NoticiaPublic])
def Obtener_Noticias_Recientes(
    session: Session = Depends(get_session),
    limit: int = 10,
):
    return LeerNoticiasRecientes(session, limit=limit)

@router.post("/noticias/", response_model=NoticiaPublic)
def Agregar_Noticia(
    noticia: NoticiaCreate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return CrearNoticia(noticia, session)

@router.get("/noticias/{id}", response_model=NoticiaPublic)
def Obtener_Noticia_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    return LeerNoticiaPorId(id, session)

@router.patch("/noticias/{id}", response_model=NoticiaPublic)
def Actualizar_Noticia(
    id: int,
    datos: NoticiaUpdate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return ActualizarNoticia(id, datos, session)

@router.delete("/noticias/{id}")
def Eliminar_Noticia(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return EliminarNoticia(id, session)