from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.lugar_cercano import LugarCercano, LugarCercanoCreate, LugarCercanoPublic, LugarCercanoUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearLugarCercano(lugar: LugarCercanoCreate, session: Session) -> LugarCercanoPublic:
    nuevo_lugar = LugarCercano(**lugar.model_dump())
    session.add(nuevo_lugar)
    session.commit()
    session.refresh(nuevo_lugar)
    return LugarCercanoPublic.model_validate(nuevo_lugar)

def LeerLugaresCercanos(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[LugarCercanoPublic]:
    lugares = session.exec(select(LugarCercano).offset(offset).limit(limit)).all()
    return [LugarCercanoPublic.model_validate(l) for l in lugares]

def LeerLugarCercanoPorId(id: int, session: Session) -> LugarCercanoPublic:
    lugar = session.get(LugarCercano, id)
    if not lugar:
        raise HTTPException(status_code=404, detail="Lugar cercano no encontrado")
    return LugarCercanoPublic.model_validate(lugar)

def LeerLugaresCercanosPorParadero(paradero_id: int, session: Session) -> List[LugarCercanoPublic]:
    lugares = session.exec(select(LugarCercano).where(LugarCercano.ParaderoId == paradero_id)).all()
    return [LugarCercanoPublic.model_validate(l) for l in lugares]

def ActualizarLugarCercano(id: int, datos: LugarCercanoUpdate, session: Session) -> LugarCercanoPublic:
    lugar_db = session.get(LugarCercano, id)
    if not lugar_db:
        raise HTTPException(status_code=404, detail="Lugar cercano no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    lugar_db.sqlmodel_update(update_data)
    session.add(lugar_db)
    session.commit()
    session.refresh(lugar_db)
    return LugarCercanoPublic.model_validate(lugar_db)

def EliminarLugarCercano(id: int, session: Session):
    lugar = session.get(LugarCercano, id)
    if not lugar:
        raise HTTPException(status_code=404, detail="Lugar cercano no encontrado")
    session.delete(lugar)
    session.commit()
    return {"message": "Lugar cercano eliminado"}