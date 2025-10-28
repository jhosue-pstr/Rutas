from typing import Annotated, List
from fastapi import Depends, HTTPException, Query, UploadFile, File, Form
from sqlmodel import Session, select
from config.database import get_session
from models.noticia import Noticia, NoticiaPublic
import os
import uuid
import shutil

SessionDep = Annotated[Session, Depends(get_session)]

# Configuración
UPLOAD_DIR = "uploads/noticias"
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/jpg", "image/webp"]

# Crear directorio si no existe
os.makedirs(UPLOAD_DIR, exist_ok=True)

def validate_and_save_image(file: UploadFile, noticia_id: int = None) -> str:
    """Valida y guarda la imagen, retorna la ruta"""
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=400, 
            detail=f"Tipo de archivo no permitido. Use: JPEG, PNG, WEBP"
        )
    
    # Verificar tamaño
    file.file.seek(0, 2)
    file_size = file.file.tell()
    file.file.seek(0)
    
    if file_size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"Archivo muy grande. Máximo: {MAX_FILE_SIZE // (1024*1024)}MB"
        )
    
    # Generar nombre único
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
    if noticia_id:
        filename = f"noticia_{noticia_id}_{uuid.uuid4().hex[:8]}.{file_extension}"
    else:
        filename = f"noticia_{uuid.uuid4().hex[:8]}.{file_extension}"
    
    file_path = os.path.join(UPLOAD_DIR, filename)
    
    # Guardar archivo
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    return f"/{UPLOAD_DIR}/{filename}"

def delete_old_image(image_path: str) -> None:
    """Elimina imagen anterior si existe"""
    if image_path and os.path.exists(image_path.lstrip('/')):
        try:
            os.remove(image_path.lstrip('/'))
        except Exception:
            pass

def CrearNoticia(
    nombre: str,
    descripcion: str,
    imagen: UploadFile,
    session: Session
) -> NoticiaPublic:
    """Crea noticia recibiendo parámetros individuales"""
    try:
        # Primero guardar la imagen
        imagen_path = validate_and_save_image(imagen)
        
        # Crear la noticia con la ruta de la imagen
        noticia_data = {
            "nombre": nombre,
            "descripcion": descripcion,
            "imagen": imagen_path
        }
        
        nueva_noticia = Noticia(**noticia_data)
        session.add(nueva_noticia)
        session.commit()
        session.refresh(nueva_noticia)
        
        # Renombrar archivo con ID de noticia
        if nueva_noticia.IdNoticia:
            file_extension = imagen.filename.split('.')[-1] if '.' in imagen.filename else 'jpg'
            new_filename = f"noticia_{nueva_noticia.IdNoticia}_{uuid.uuid4().hex[:8]}.{file_extension}"
            new_path = f"/{UPLOAD_DIR}/{new_filename}"
            old_path = nueva_noticia.imagen.lstrip('/')
            
            if os.path.exists(old_path):
                os.rename(old_path, new_path.lstrip('/'))
                nueva_noticia.imagen = new_path
                session.add(nueva_noticia)
                session.commit()
                session.refresh(nueva_noticia)
        
        return NoticiaPublic.model_validate(nueva_noticia)
        
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al crear noticia: {str(e)}")

def LeerNoticias(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[NoticiaPublic]:
    try:
        noticias = session.exec(select(Noticia).offset(offset).limit(limit)).all()
        return [NoticiaPublic.model_validate(n) for n in noticias]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener noticias: {str(e)}")

def LeerNoticiasRecientes(session: Session, limit: int = 10) -> List[NoticiaPublic]:
    try:
        noticias = session.exec(
            select(Noticia).order_by(Noticia.fechaPublicacion.desc()).limit(limit)
        ).all()
        return [NoticiaPublic.model_validate(n) for n in noticias]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener noticias recientes: {str(e)}")

def LeerNoticiaPorId(id: int, session: Session) -> NoticiaPublic:
    try:
        noticia = session.get(Noticia, id)
        if not noticia:
            raise HTTPException(status_code=404, detail="Noticia no encontrada")
        return NoticiaPublic.model_validate(noticia)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener noticia: {str(e)}")

def ActualizarNoticia(
    id: int,
    nombre: str = None,
    descripcion: str = None,
    imagen: UploadFile = None,
    session: Session = None
) -> NoticiaPublic:
    try:
        noticia_db = session.get(Noticia, id)
        if not noticia_db:
            raise HTTPException(status_code=404, detail="Noticia no encontrada")

        # Actualizar campos básicos
        update_data = {}
        if nombre is not None:
            update_data["nombre"] = nombre
        if descripcion is not None:
            update_data["descripcion"] = descripcion
        
        if update_data:
            noticia_db.sqlmodel_update(update_data)
        
        # Procesar imagen si se proporciona
        if imagen:
            # Eliminar imagen anterior si existe
            if noticia_db.imagen:
                delete_old_image(noticia_db.imagen)
            
            # Guardar nueva imagen
            noticia_db.imagen = validate_and_save_image(imagen, id)
        
        session.add(noticia_db)
        session.commit()
        session.refresh(noticia_db)
        return NoticiaPublic.model_validate(noticia_db)
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al actualizar noticia: {str(e)}")

def EliminarNoticia(id: int, session: Session):
    try:
        noticia = session.get(Noticia, id)
        if not noticia:
            raise HTTPException(status_code=404, detail="Noticia no encontrada")
        
        # Eliminar imagen asociada
        if noticia.imagen:
            delete_old_image(noticia.imagen)
        
        session.delete(noticia)
        session.commit()
        return {"message": "Noticia eliminada correctamente"}
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al eliminar noticia: {str(e)}")