from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.lugar_favorito import LugarFavorito, LugarFavoritoCreate, LugarFavoritoPublic, LugarFavoritoUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearLugarFavorito(lugar: LugarFavoritoCreate, session: Session) -> LugarFavoritoPublic:
    nuevo_lugar = LugarFavorito(**lugar.model_dump())
    session.add(nuevo_lugar)
    session.commit()
    session.refresh(nuevo_lugar)
    return LugarFavoritoPublic.model_validate(nuevo_lugar)

def LeerLugaresFavoritos(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[LugarFavoritoPublic]:
    lugares = session.exec(select(LugarFavorito).offset(offset).limit(limit)).all()
    return [LugarFavoritoPublic.model_validate(l) for l in lugares]

def LeerLugaresFavoritosPorUsuario(IdUsuario: int, session: Session) -> List[LugarFavoritoPublic]:
    lugares = session.exec(
        select(LugarFavorito).where(LugarFavorito.IdUsuario == IdUsuario)
    ).all()
    return [LugarFavoritoPublic.model_validate(l) for l in lugares]

def LeerLugarFavoritoPorId(id: int, session: Session) -> LugarFavoritoPublic:
    lugar = session.get(LugarFavorito, id)
    if not lugar:
        raise HTTPException(status_code=404, detail="Lugar favorito no encontrado")
    return LugarFavoritoPublic.model_validate(lugar)

def ActualizarLugarFavorito(id: int, datos: LugarFavoritoUpdate, session: Session) -> LugarFavoritoPublic:
    lugar_db = session.get(LugarFavorito, id)
    if not lugar_db:
        raise HTTPException(status_code=404, detail="Lugar favorito no encontrado")

    update_data = datos.model_dump(exclude_unset=True)
    lugar_db.sqlmodel_update(update_data)
    session.add(lugar_db)
    session.commit()
    session.refresh(lugar_db)
    return LugarFavoritoPublic.model_validate(lugar_db)

def EliminarLugarFavorito(id: int, session: Session):
    lugar = session.get(LugarFavorito, id)
    if not lugar:
        raise HTTPException(status_code=404, detail="Lugar favorito no encontrado")
    session.delete(lugar)
    session.commit()
    return {"message": "Lugar favorito eliminado"}