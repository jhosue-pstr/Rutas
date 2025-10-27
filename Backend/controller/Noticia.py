from typing import Annotated, List
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.noticia import Noticia, NoticiaCreate, NoticiaPublic, NoticiaUpdate

SessionDep = Annotated[Session, Depends(get_session)]

def CrearNoticia(noticia: NoticiaCreate, session: Session) -> NoticiaPublic:
    nueva_noticia = Noticia(**noticia.model_dump())
    session.add(nueva_noticia)
    session.commit()
    session.refresh(nueva_noticia)
    return NoticiaPublic.model_validate(nueva_noticia)

def LeerNoticias(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[NoticiaPublic]:
    noticias = session.exec(select(Noticia).offset(offset).limit(limit)).all()
    return [NoticiaPublic.model_validate(n) for n in noticias]

def LeerNoticiasRecientes(session: Session, limit: int = 10) -> List[NoticiaPublic]:
    noticias = session.exec(select(Noticia).order_by(Noticia.FechaPublicacion.desc()).limit(limit)).all()
    return [NoticiaPublic.model_validate(n) for n in noticias]

def LeerNoticiaPorId(id: int, session: Session) -> NoticiaPublic:
    noticia = session.get(Noticia, id)
    if not noticia:
        raise HTTPException(status_code=404, detail="Noticia no encontrada")
    return NoticiaPublic.model_validate(noticia)

def ActualizarNoticia(id: int, datos: NoticiaUpdate, session: Session) -> NoticiaPublic:
    noticia_db = session.get(Noticia, id)
    if not noticia_db:
        raise HTTPException(status_code=404, detail="Noticia no encontrada")

    update_data = datos.model_dump(exclude_unset=True)
    noticia_db.sqlmodel_update(update_data)
    session.add(noticia_db)
    session.commit()
    session.refresh(noticia_db)
    return NoticiaPublic.model_validate(noticia_db)

def EliminarNoticia(id: int, session: Session):
    noticia = session.get(Noticia, id)
    if not noticia:
        raise HTTPException(status_code=404, detail="Noticia no encontrada")
    session.delete(noticia)
    session.commit()
    return {"message": "Noticia eliminada"}