from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException
from sqlmodel import Session
from config.database import get_session
from models.noticia import NoticiaPublic
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
    """Obtener lista de noticias con paginación"""
    return LeerNoticias(session, offset=offset, limit=limit)

@router.get("/noticias/recientes/", response_model=list[NoticiaPublic])
def Obtener_Noticias_Recientes(
    session: Session = Depends(get_session),
    limit: int = 10,
):
    """Obtener noticias más recientes"""
    return LeerNoticiasRecientes(session, limit=limit)

@router.post("/noticias/", response_model=NoticiaPublic)
def Agregar_Noticia(
    nombre: str = Form(..., description="Título de la noticia"),
    descripcion: str = Form(..., description="Descripción de la noticia"),
    imagen: UploadFile = File(..., description="Imagen de la noticia"),
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    """Crear una nueva noticia"""
    try:
        return CrearNoticia(
            nombre=nombre,
            descripcion=descripcion,
            imagen=imagen,
            session=session
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/noticias/{id}", response_model=NoticiaPublic)
def Obtener_Noticia_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    """Obtener una noticia específica por ID"""
    return LeerNoticiaPorId(id, session)

@router.patch("/noticias/{id}", response_model=NoticiaPublic)
def Actualizar_Noticia(
    id: int,
    nombre: str = Form(None),
    descripcion: str = Form(None),
    imagen: UploadFile = File(None),
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    """Actualizar información de una noticia existente"""
    try:
        return ActualizarNoticia(
            id=id,
            nombre=nombre,
            descripcion=descripcion,
            imagen=imagen,
            session=session
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/noticias/{id}")
def Eliminar_Noticia(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    """Eliminar una noticia por ID"""
    return EliminarNoticia(id, session)