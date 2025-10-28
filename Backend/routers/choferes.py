from fastapi import APIRouter, Depends, File, UploadFile, Form, HTTPException
from sqlmodel import Session
from controller import Chofer
from config.database import get_session
from models.chofer import ChoferPublic
from controller.Chofer import (
    LeerChoferes, CrearChofer, LeerChoferPorId, 
    ActualizarChofer, EliminarChofer
)

router = APIRouter()

@router.get("/choferes/", response_model=list[ChoferPublic])
def Obtener_Choferes(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
):
    """Obtener lista de choferes con paginación"""
    return LeerChoferes(session, offset=offset, limit=limit)

@router.post("/choferes/", response_model=ChoferPublic)
def Agregar_Chofer(
    nombre: str = Form(..., description="Nombre del chofer"),
    apellido: str = Form(None, description="Apellido del chofer"),
    dni: str = Form(None, description="DNI del chofer"),
    telefono: str = Form(None, description="Teléfono del chofer"),
    foto: UploadFile = File(None, description="Foto del chofer"),
    qr_pago: UploadFile = File(None, description="QR de pago"),
    licencia_img: UploadFile = File(None, description="Imagen de licencia de conducir"),
    session: Session = Depends(get_session),
):
    """Crear un nuevo chofer con información e imágenes opcionales"""
    try:
        return CrearChofer(
            nombre=nombre,
            apellido=apellido,
            dni=dni,
            telefono=telefono,
            foto=foto,
            qr_pago=qr_pago,
            licencia_img=licencia_img,
            session=session
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/choferes/{id}", response_model=ChoferPublic)
def Obtener_Chofer_Por_Id(
    id: int,
    session: Session = Depends(get_session),
):
    """Obtener un chofer específico por ID"""
    return LeerChoferPorId(id, session)

@router.patch("/choferes/{id}", response_model=ChoferPublic)
def Actualizar_Chofer(
    id: int,
    nombre: str = Form(None),
    apellido: str = Form(None),
    dni: str = Form(None),
    telefono: str = Form(None),
    foto: UploadFile = File(None),
    qr_pago: UploadFile = File(None),
    licencia_img: UploadFile = File(None),
    session: Session = Depends(get_session),
):
    """Actualizar información de un chofer existente"""
    try:
        return ActualizarChofer(
            id=id,
            nombre=nombre,
            apellido=apellido,
            dni=dni,
            telefono=telefono,
            foto=foto,
            qr_pago=qr_pago,
            licencia_img=licencia_img,
            session=session
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/choferes/{id}")
def Eliminar_Chofer(
    id: int,
    session: Session = Depends(get_session),
):
    """Eliminar un chofer por ID"""
    return EliminarChofer(id, session)

@router.get("/choferes/{id}/imagen/{tipo_imagen}")
def Obtener_Imagen_Chofer(
    id: int,
    tipo_imagen: str,  # foto, qr_pago, licencia
    session: Session = Depends(get_session),
):
    """Obtener imagen específica de un chofer"""
    chofer = session.get(Chofer, id)
    if not chofer:
        raise HTTPException(status_code=404, detail="Chofer no encontrado")
    
    image_path = None
    if tipo_imagen == "foto":
        image_path = chofer.foto_url
    elif tipo_imagen == "qr_pago":
        image_path = chofer.qr_pago_url
    elif tipo_imagen == "licencia":
        image_path = chofer.licencia_conducir
    
    if not image_path:
        raise HTTPException(status_code=404, detail="Imagen no encontrada")
    
    # Servir la imagen (implementar según tu configuración de archivos estáticos)
    return {"image_url": image_path}