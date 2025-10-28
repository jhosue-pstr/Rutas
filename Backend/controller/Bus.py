from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.bus import Bus, BusCreate, BusPublic, BusUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearBus(bus: BusCreate, session: Session) -> BusPublic:
    nuevo_bus = Bus(**bus.model_dump())
    session.add(nuevo_bus)
    session.commit()
    session.refresh(nuevo_bus)
    return BusPublic.model_validate(nuevo_bus)

def LeerBuses(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[BusPublic]:
    buses = session.exec(select(Bus).offset(offset).limit(limit)).all()
    return [BusPublic.model_validate(b) for b in buses]

def LeerBusPorId(id: int, session: Session) -> BusPublic:
    bus = session.get(Bus, id)
    if not bus:
        raise HTTPException(status_code=404, detail="Bus no encontrado")
    return BusPublic.model_validate(bus)

def ActualizarBus(id: int, datos: BusUpdate, session: Session) -> BusPublic:
    bus_db = session.get(Bus, id)
    if not bus_db:
        raise HTTPException(status_code=404, detail="Bus no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    bus_db.sqlmodel_update(update_data)
    session.add(bus_db)
    session.commit()
    session.refresh(bus_db)
    return BusPublic.model_validate(bus_db)

def EliminarBus(id: int, session: Session):
    bus = session.get(Bus, id)
    if not bus:
        raise HTTPException(status_code=404, detail="Bus no encontrado")
    session.delete(bus)
    session.commit()
    return {"message": "Bus eliminado"}
