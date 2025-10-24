from fastapi import APIRouter, Depends
from sqlmodel import Session
from config.database import get_session
from models.usuario import UsuarioCreate, UsuarioPublic, UsuarioUpdate
from controlers.Usuario import (
    LeerUsuarios, CrearUsuario, LeerUsuarioPorId, ActualizarUsuario, EliminarUsuario
)
from routers.auth import get_current_active_user  
from models.usuario import Usuario  

router = APIRouter()

@router.get("/usuarios/", response_model=list[UsuarioPublic])
def ObtenerUsuario(
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = 100,
    current_user: Usuario = Depends(get_current_active_user)
):
    return LeerUsuarios(session, offset=offset, limit=limit)

@router.post("/usuarios/", response_model=UsuarioPublic)
def Agregar_Usuario(
    usuario: UsuarioCreate, 
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user)
):
    return CrearUsuario(usuario, session)

@router.get("/usuarios/{IdUsuario}", response_model=UsuarioPublic)
def Obtener_Usuario_Por_Id(
    IdUsuario: int, 
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user) 
):
    return LeerUsuarioPorId(IdUsuario, session)

@router.patch("/usuarios/{IdUsuario}", response_model=UsuarioPublic)
def Actualizar_Usuario(
    IdUsuario: int, 
    datos: UsuarioUpdate, 
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user) 
):
    return ActualizarUsuario(IdUsuario, datos, session)

@router.delete("/usuarios/{IdUsuario}")
def Eliminar_Usuario(
    IdUsuario: int, 
    session: Session = Depends(get_session),
    current_user: Usuario = Depends(get_current_active_user) 
):
    return EliminarUsuario(IdUsuario, session)

# Nueva ruta para obtener el usuario actual
@router.get("/usuarios/me/", response_model=UsuarioPublic)
def Obtener_Usuario_Actual(
    current_user: Usuario = Depends(get_current_active_user)
):
    return UsuarioPublic.model_validate(current_user)