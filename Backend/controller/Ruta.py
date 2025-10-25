from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.ruta import Ruta, RutaCreate, RutaPublic, RutaUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearRuta(ruta: RutaCreate, session: Session) -> RutaPublic:
    nueva_ruta = Ruta(
        nombre=ruta.Nombre,
        color=ruta.Color,
        descripcion=ruta.Descripcion
    )
    session.add(nueva_ruta)
    session.commit()
    session.refresh(nueva_ruta)
    return RutaPublic.model_validate(nueva_ruta)

def LeerRutas(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[RutaPublic]:
    rutas = session.exec(select(Ruta).offset(offset).limit(limit)).all()
    return [RutaPublic.model_validate(r) for r in rutas]

def LeerRutaPorId(id: int, session: Session) -> RutaPublic:
    ruta = session.get(Ruta, id)
    if not ruta:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    return RutaPublic.model_validate(ruta)

def ActualizarRuta(id: int, datos: RutaUpdate, session: Session) -> RutaPublic:
    ruta_db = session.get(Ruta, id)
    if not ruta_db:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")

    update_data = datos.model_dump(exclude_unset=True)
    ruta_db.sqlmodel_update(update_data)
    session.add(ruta_db)
    session.commit()
    session.refresh(ruta_db)
    return RutaPublic.model_validate(ruta_db)

def EliminarRuta(id: int, session: Session):
    ruta = session.get(Ruta, id)
    if not ruta:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    session.delete(ruta)
    session.commit()
    return {"message": "Ruta eliminada"}
