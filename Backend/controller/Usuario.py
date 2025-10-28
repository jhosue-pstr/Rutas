from typing import Annotated
from fastapi import Depends, HTTPException, Query
from sqlmodel import Session, select
from config.database import get_session
from models.usuario import Usuario, UsuarioCreate, UsuarioPublic, UsuarioUpdate
from controller.auth import get_password_hash, get_user_by_email
import datetime

SessionDep = Annotated[Session, Depends(get_session)]

def CrearUsuario(usuario: UsuarioCreate, session: Session) -> UsuarioPublic:
    existing_user = get_user_by_email(session, usuario.Correo)
    if existing_user:
        raise HTTPException(
            status_code=400,    
            detail="El correo ya está registrado"
        )
    
    hashed_password = get_password_hash(usuario.Contrasena)
    
    nuevo_usuario = Usuario(
        Nombre=usuario.Nombre,
        Apellido=usuario.Apellido,
        Correo=usuario.Correo,
        Contrasena=hashed_password, 
        estado=True
    )
    
    session.add(nuevo_usuario)
    session.commit()
    session.refresh(nuevo_usuario)
    return UsuarioPublic.model_validate(nuevo_usuario)

def LeerUsuarios(
    session: Session,
    offset: int = 0,
    limit: Annotated[int, Query(le=100)] = 100,
) -> list[UsuarioPublic]:
    usuarios = session.exec(select(Usuario).offset(offset).limit(limit)).all()
    return [UsuarioPublic.model_validate(u) for u in usuarios]

def LeerUsuarioPorId(IdUsuario: int, session: Session) -> UsuarioPublic:
    usuario = session.get(Usuario, IdUsuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return UsuarioPublic.model_validate(usuario)

def ActualizarUsuario(IdUsuario: int, datos: UsuarioUpdate, session: Session) -> UsuarioPublic:
    usuario_db = session.get(Usuario, IdUsuario)
    if not usuario_db:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    update_data = datos.model_dump(exclude_unset=True)
    
    # Si se actualiza la contraseña, hashearla
    if 'Contrasena' in update_data and update_data['Contrasena']:
        from controlers.auth import get_password_hash
        update_data['Contrasena'] = get_password_hash(update_data['Contrasena'])
    
    usuario_db.sqlmodel_update(update_data)

    session.add(usuario_db)
    session.commit()
    session.refresh(usuario_db)
    return UsuarioPublic.model_validate(usuario_db)

def EliminarUsuario(IdUsuario: int, session: Session):
    usuario = session.get(Usuario, IdUsuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    session.delete(usuario)
    session.commit()
    return {"message": "Usuario eliminado"}

def LeerUsuarioPorCorreo(correo: str, session: Session) -> UsuarioPublic:
    from controlers.auth import get_user_by_email
    usuario = get_user_by_email(session, correo)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return UsuarioPublic.model_validate(usuario)