from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.chofer import Chofer, ChoferCreate, ChoferPublic, ChoferUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearChofer(chofer: ChoferCreate, session: Session) -> ChoferPublic:
    nuevo_chofer = Chofer(**chofer.model_dump())
    session.add(nuevo_chofer)
    session.commit()
    session.refresh(nuevo_chofer)
    return ChoferPublic.model_validate(nuevo_chofer)

def LeerChoferes(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[ChoferPublic]:
    choferes = session.exec(select(Chofer).offset(offset).limit(limit)).all()
    return [ChoferPublic.model_validate(c) for c in choferes]

def LeerChoferPorId(id: int, session: Session) -> ChoferPublic:
    chofer = session.get(Chofer, id)
    if not chofer:
        raise HTTPException(status_code=404, detail="Chofer no encontrado")
    return ChoferPublic.model_validate(chofer)

def ActualizarChofer(id: int, datos: ChoferUpdate, session: Session) -> ChoferPublic:
    chofer_db = session.get(Chofer, id)
    if not chofer_db:
        raise HTTPException(status_code=404, detail="Chofer no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    chofer_db.sqlmodel_update(update_data)
    session.add(chofer_db)
    session.commit()
    session.refresh(chofer_db)
    return ChoferPublic.model_validate(chofer_db)

def EliminarChofer(id: int, session: Session):
    chofer = session.get(Chofer, id)
    if not chofer:
        raise HTTPException(status_code=404, detail="Chofer no encontrado")
    session.delete(chofer)
    session.commit()
    return {"message": "Chofer eliminado"}
