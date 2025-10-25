from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.chofer import ChoferCreate, ChoferPublic, ChoferUpdate
from controller.Chofer import (
    LeerChoferes, CrearChofer, LeerChoferPorId, ActualizarChofer, EliminarChofer
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/choferes/", response_model=list[ChoferPublic])
def Obtener_Choferes(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
    current_user: Usuario = Depends(get_current_active_user)
):
    return LeerChoferes(session, offset=offset, limit=limit)

@router.post("/choferes/", response_model=ChoferPublic)
def Agregar_Chofer(
    chofer: ChoferCreate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return CrearChofer(chofer, session)

@router.get("/choferes/{id}", response_model=ChoferPublic)
def Obtener_Chofer_Por_Id(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return LeerChoferPorId(id, session)

@router.patch("/choferes/{id}", response_model=ChoferPublic)
def Actualizar_Chofer(
    id: int,
    datos: ChoferUpdate,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return ActualizarChofer(id, datos, session)

@router.delete("/choferes/{id}")
def Eliminar_Chofer(
    id: int,
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return EliminarChofer(id, session)
