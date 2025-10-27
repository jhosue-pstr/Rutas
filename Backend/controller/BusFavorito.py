from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.bus_favorito import BusFavorito, BusFavoritoCreate, BusFavoritoPublic, BusFavoritoUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearBusFavorito(bus_favorito: BusFavoritoCreate, session: Session) -> BusFavoritoPublic:
    # Verificar si ya existe
    existente = session.exec(
        select(BusFavorito)
        .where(BusFavorito.IdUsuario == bus_favorito.IdUsuario) 
        .where(BusFavorito.IdBus == bus_favorito.IdBus) 
    ).first()
    
    if existente:
        raise HTTPException(status_code=400, detail="El bus ya está en favoritos")

    nuevo_favorito = BusFavorito(**bus_favorito.model_dump())
    session.add(nuevo_favorito)
    session.commit()
    session.refresh(nuevo_favorito)
    return BusFavoritoPublic.model_validate(nuevo_favorito)

def LeerBusesFavoritos(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[BusFavoritoPublic]:
    favoritos = session.exec(select(BusFavorito).offset(offset).limit(limit)).all()
    return [BusFavoritoPublic.model_validate(f) for f in favoritos]

def LeerBusesFavoritosPorUsuario(usuario_id: int, session: Session) -> List[BusFavoritoPublic]:
    favoritos = session.exec(
        select(BusFavorito).where(BusFavorito.UsuarioId == usuario_id)
    ).all()
    return [BusFavoritoPublic.model_validate(f) for f in favoritos]

def LeerBusFavoritoPorId(id: int, session: Session) -> BusFavoritoPublic:
    favorito = session.get(BusFavorito, id)
    if not favorito:
        raise HTTPException(status_code=404, detail="Bus favorito no encontrado")
    return BusFavoritoPublic.model_validate(favorito)

def EliminarBusFavorito(id: int, session: Session):
    favorito = session.get(BusFavorito, id)
    if not favorito:
        raise HTTPException(status_code=404, detail="Bus favorito no encontrado")
    session.delete(favorito)
    session.commit()
    return {"message": "Bus eliminado de favoritos"}

def EliminarBusFavoritoPorUsuarioYBuses(usuario_id: int, bus_id: int, session: Session):
    favorito = session.exec(
        select(BusFavorito)
        .where(BusFavorito.UsuarioId == usuario_id)
        .where(BusFavorito.BusId == bus_id)
    ).first()
    
    if not favorito:
        raise HTTPException(status_code=404, detail="Bus favorito no encontrado")
    
    session.delete(favorito)
    session.commit()
    return {"message": "Bus eliminado de favoritos"}