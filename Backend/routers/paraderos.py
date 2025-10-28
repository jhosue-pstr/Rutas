from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.paradero import ParaderoCreate, ParaderoPublic, ParaderoUpdate
from controller.Paradero import (
    LeerParaderos, CrearParadero, LeerParaderoPorId, ActualizarParadero, EliminarParadero
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/paraderos/", response_model=list[ParaderoPublic])
def Obtener_Paraderos(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
):
    return LeerParaderos(session, offset=offset, limit=limit)

@router.post("/paraderos/", response_model=ParaderoPublic)
def Agregar_Paradero(
    paradero: ParaderoCreate,
    session: Session = Depends(get_session),
):
    return CrearParadero(paradero, session)

@router.get("/paraderos/{id}", response_model=ParaderoPublic)
def Obtener_Paradero_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    return LeerParaderoPorId(id, session)

@router.patch("/paraderos/{id}", response_model=ParaderoPublic)
def Actualizar_Paradero(
    id: int,
    datos: ParaderoUpdate,
    session: Session = Depends(get_session),
):
    return ActualizarParadero(id, datos, session)

@router.delete("/paraderos/{id}")
def Eliminar_Paradero(
    id: int,
    session: Session = Depends(get_session),
):
    return EliminarParadero(id, session)