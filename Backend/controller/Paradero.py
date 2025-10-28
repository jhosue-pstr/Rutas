from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.paradero import Paradero, ParaderoCreate, ParaderoPublic, ParaderoUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearParadero(paradero: ParaderoCreate, session: Session) -> ParaderoPublic:
    nuevo_paradero = Paradero(**paradero.model_dump())
    session.add(nuevo_paradero)
    session.commit()
    session.refresh(nuevo_paradero)
    return ParaderoPublic.model_validate(nuevo_paradero)

def LeerParaderos(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[ParaderoPublic]:
    paraderos = session.exec(select(Paradero).offset(offset).limit(limit)).all()
    return [ParaderoPublic.model_validate(p) for p in paraderos]

def LeerParaderoPorId(id: int, session: Session) -> ParaderoPublic:
    paradero = session.get(Paradero, id)
    if not paradero:
        raise HTTPException(status_code=404, detail="Paradero no encontrado")
    return ParaderoPublic.model_validate(paradero)

def ActualizarParadero(id: int, datos: ParaderoUpdate, session: Session) -> ParaderoPublic:
    paradero_db = session.get(Paradero, id)
    if not paradero_db:
        raise HTTPException(status_code=404, detail="Paradero no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    paradero_db.sqlmodel_update(update_data)
    session.add(paradero_db)
    session.commit()
    session.refresh(paradero_db)
    return ParaderoPublic.model_validate(paradero_db)

def EliminarParadero(id: int, session: Session):
    paradero = session.get(Paradero, id)
    if not paradero:
        raise HTTPException(status_code=404, detail="Paradero no encontrado")
    session.delete(paradero)
    session.commit()
    return {"message": "Paradero eliminado"}