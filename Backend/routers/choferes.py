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
):
    return LeerChoferes(session, offset=offset, limit=limit)

@router.post("/choferes/", response_model=ChoferPublic)
def Agregar_Chofer(
    chofer: ChoferCreate,
    session: Session = Depends(get_session),
):
    return CrearChofer(chofer, session)

@router.get("/choferes/{id}", response_model=ChoferPublic)
def Obtener_Chofer_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    return LeerChoferPorId(id, session)

@router.patch("/choferes/{id}", response_model=ChoferPublic)
def Actualizar_Chofer(
    id: int,
    datos: ChoferUpdate,
    session: Session = Depends(get_session),
):
    return ActualizarChofer(id, datos, session)

@router.delete("/choferes/{id}")
def Eliminar_Chofer(
    id: int,
    session: Session = Depends(get_session),
):
    return EliminarChofer(id, session)
