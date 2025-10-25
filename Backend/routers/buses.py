from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.bus import BusCreate, BusPublic, BusUpdate
from controller.Bus import (
    LeerBuses, CrearBus, LeerBusPorId, ActualizarBus, EliminarBus
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/buses/", response_model=list[BusPublic])
def Obtener_Buses(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
):
    return LeerBuses(session, offset=offset, limit=limit)

@router.post("/buses/", response_model=BusPublic)
def Agregar_Bus(
    bus: BusCreate,
    session: Session = Depends(get_session),
):
    return CrearBus(bus, session)

@router.get("/buses/{id}", response_model=BusPublic)
def Obtener_Bus_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    return LeerBusPorId(id, session)

@router.patch("/buses/{id}", response_model=BusPublic)
def Actualizar_Bus(
    id: int,
    datos: BusUpdate,
    session: Session = Depends(get_session),
):
    return ActualizarBus(id, datos, session)

@router.delete("/buses/{id}")
def Eliminar_Bus(
    id: int,
    session: Session = Depends(get_session),
):
    return EliminarBus(id, session)
