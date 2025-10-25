from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.punto_ruta import PuntoRuta, PuntoRutaCreate, PuntoRutaPublic, PuntoRutaUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearPuntoRuta(punto: PuntoRutaCreate, session: Session) -> PuntoRutaPublic:
    nuevo_punto = PuntoRuta(**punto.model_dump())
    session.add(nuevo_punto)
    session.commit()
    session.refresh(nuevo_punto)
    return PuntoRutaPublic.model_validate(nuevo_punto)

def LeerPuntosRuta(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[PuntoRutaPublic]:
    puntos = session.exec(select(PuntoRuta).offset(offset).limit(limit)).all()
    return [PuntoRutaPublic.model_validate(p) for p in puntos]

def LeerPuntoRutaPorId(id: int, session: Session) -> PuntoRutaPublic:
    punto = session.get(PuntoRuta, id)
    if not punto:
        raise HTTPException(status_code=404, detail="Punto no encontrado")
    return PuntoRutaPublic.model_validate(punto)

def ActualizarPuntoRuta(id: int, datos: PuntoRutaUpdate, session: Session) -> PuntoRutaPublic:
    punto_db = session.get(PuntoRuta, id)
    if not punto_db:
        raise HTTPException(status_code=404, detail="Punto no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    punto_db.sqlmodel_update(update_data)
    session.add(punto_db)
    session.commit()
    session.refresh(punto_db)
    return PuntoRutaPublic.model_validate(punto_db)

def EliminarPuntoRuta(id: int, session: Session):
    punto = session.get(PuntoRuta, id)
    if not punto:
        raise HTTPException(status_code=404, detail="Punto no encontrado")
    session.delete(punto)
    session.commit()
    return {"message": "Punto eliminado"}
