from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.lugar_cercano import LugarCercanoCreate, LugarCercanoPublic, LugarCercanoUpdate
from controller.LugarCercano import (
    LeerLugaresCercanos, CrearLugarCercano, LeerLugarCercanoPorId, 
    ActualizarLugarCercano, EliminarLugarCercano, LeerLugaresCercanosPorParadero
)
from routers.auth import get_current_active_user
from models.usuario import Usuario

router = APIRouter()

@router.get("/lugares_cercanos/", response_model=list[LugarCercanoPublic])
def Obtener_Lugares_Cercanos(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
):
    return LeerLugaresCercanos(session, offset=offset, limit=limit)

@router.post("/lugares_cercanos/", response_model=LugarCercanoPublic)
def Agregar_Lugar_Cercano(
    lugar: LugarCercanoCreate,
    session: Session = Depends(get_session),
):
    return CrearLugarCercano(lugar, session)

@router.get("/lugares_cercanos/{id}", response_model=LugarCercanoPublic)
def Obtener_Lugar_Cercano_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    return LeerLugarCercanoPorId(id, session)

@router.get("/paraderos/{paradero_id}/lugares_cercanos/", response_model=list[LugarCercanoPublic])
def Obtener_Lugares_Cercanos_Por_Paradero(
    paradero_id: int,
    session: Session = Depends(get_session),
):
    return LeerLugaresCercanosPorParadero(paradero_id, session)

@router.patch("/lugares_cercanos/{id}", response_model=LugarCercanoPublic)
def Actualizar_Lugar_Cercano(
    id: int,
    datos: LugarCercanoUpdate,
    session: Session = Depends(get_session),
):
    return ActualizarLugarCercano(id, datos, session)

@router.delete("/lugares_cercanos/{id}")
def Eliminar_Lugar_Cercano(
    id: int,
    session: Session = Depends(get_session),
):
    return EliminarLugarCercano(id, session)