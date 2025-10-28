from typing import Annotated, List
from fastapi import Depends, HTTPException, Query, UploadFile, File, Form
from sqlmodel import Session, select
from config.database import get_session
from models.chofer import Chofer, ChoferCreate, ChoferPublic, ChoferUpdate
import os
import uuid
import shutil

SessionDep = Annotated[Session, Depends(get_session)]

# Configuración
UPLOAD_DIR = "uploads/choferes"
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/jpg", "image/webp"]

# Crear directorio si no existe
os.makedirs(UPLOAD_DIR, exist_ok=True)

def validate_and_save_image(file: UploadFile, chofer_id: int, image_type: str) -> str:
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
    filename = f"{image_type}_{chofer_id}_{uuid.uuid4().hex[:8]}.{file_extension}"
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

def CrearChofer(
    nombre: str,
    apellido: str = None,
    dni: str = None,
    telefono: str = None,
    foto: UploadFile = None,
    qr_pago: UploadFile = None,
    licencia_img: UploadFile = None,
    session: Session = None
) -> ChoferPublic:
    """Crea chofer recibiendo parámetros individuales"""
    try:
        # Crear el chofer sin las imágenes primero
        chofer_data = {
            "nombre": nombre,
            "apellido": apellido,
            "dni": dni,
            "telefono": telefono
        }
        
        nuevo_chofer = Chofer(**chofer_data)
        session.add(nuevo_chofer)
        session.commit()
        session.refresh(nuevo_chofer)
        
        # Procesar imágenes después de crear el chofer
        image_updates = {}
        
        if foto:
            image_updates["foto_url"] = validate_and_save_image(foto, nuevo_chofer.IdChofer, "foto")
        
        if qr_pago:
            image_updates["qr_pago_url"] = validate_and_save_image(qr_pago, nuevo_chofer.IdChofer, "qr_pago")
        
        if licencia_img:
            image_updates["licencia_conducir"] = validate_and_save_image(licencia_img, nuevo_chofer.IdChofer, "licencia")
        
        # Actualizar con las URLs de las imágenes
        if image_updates:
            for key, value in image_updates.items():
                setattr(nuevo_chofer, key, value)
            
            session.add(nuevo_chofer)
            session.commit()
            session.refresh(nuevo_chofer)
        
        return ChoferPublic.model_validate(nuevo_chofer)
        
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al crear chofer: {str(e)}")

def LeerChoferes(session: Session, offset: int = 0, limit: Annotated[int, Query(le=100)] = 100) -> List[ChoferPublic]:
    try:
        choferes = session.exec(select(Chofer).offset(offset).limit(limit)).all()
        return [ChoferPublic.model_validate(c) for c in choferes]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener choferes: {str(e)}")

def LeerChoferPorId(id: int, session: Session) -> ChoferPublic:
    try:
        chofer = session.get(Chofer, id)
        if not chofer:
            raise HTTPException(status_code=404, detail="Chofer no encontrado")
        return ChoferPublic.model_validate(chofer)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener chofer: {str(e)}")

def ActualizarChofer(
    id: int,
    nombre: str = None,
    apellido: str = None,
    dni: str = None,
    telefono: str = None,
    foto: UploadFile = None,
    qr_pago: UploadFile = None,
    licencia_img: UploadFile = None,
    session: Session = None
) -> ChoferPublic:
    try:
        chofer_db = session.get(Chofer, id)
        if not chofer_db:
            raise HTTPException(status_code=404, detail="Chofer no encontrado")

        # Actualizar campos básicos
        update_data = {}
        if nombre is not None:
            update_data["nombre"] = nombre
        if apellido is not None:
            update_data["apellido"] = apellido
        if dni is not None:
            update_data["dni"] = dni
        if telefono is not None:
            update_data["telefono"] = telefono
        
        if update_data:
            chofer_db.sqlmodel_update(update_data)
        
        # Procesar imágenes
        if foto:
            if chofer_db.foto_url:
                delete_old_image(chofer_db.foto_url)
            chofer_db.foto_url = validate_and_save_image(foto, id, "foto")
        
        if qr_pago:
            if chofer_db.qr_pago_url:
                delete_old_image(chofer_db.qr_pago_url)
            chofer_db.qr_pago_url = validate_and_save_image(qr_pago, id, "qr_pago")
        
        if licencia_img:
            if chofer_db.licencia_conducir:
                delete_old_image(chofer_db.licencia_conducir)
            chofer_db.licencia_conducir = validate_and_save_image(licencia_img, id, "licencia")
        
        session.add(chofer_db)
        session.commit()
        session.refresh(chofer_db)
        return ChoferPublic.model_validate(chofer_db)
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al actualizar chofer: {str(e)}")

def EliminarChofer(id: int, session: Session):
    try:
        chofer = session.get(Chofer, id)
        if not chofer:
            raise HTTPException(status_code=404, detail="Chofer no encontrado")
        
        # Eliminar imágenes
        if chofer.foto_url:
            delete_old_image(chofer.foto_url)
        if chofer.qr_pago_url:
            delete_old_image(chofer.qr_pago_url)
        if chofer.licencia_conducir:
            delete_old_image(chofer.licencia_conducir)
        
        session.delete(chofer)
        session.commit()
        return {"message": "Chofer eliminado correctamente"}
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error al eliminar chofer: {str(e)}")