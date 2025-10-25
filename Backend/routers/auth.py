from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import Session
from datetime import timedelta

from config.database import get_session
from models.usuario import Token, UserLogin, UsuarioPublic, UsuarioCreate
from controller.auth import authenticate_user, create_access_token, get_current_user
from controller.Usuario import CrearUsuario
from models.usuario import Usuario

router = APIRouter(prefix="/auth", tags=["authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

@router.post("/login", response_model=Token)
async def login_for_access_token(
    login_data: UserLogin,
    db: Session = Depends(get_session)
):
    user = authenticate_user(db, login_data.Correo, login_data.Contrasena)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": user.Correo}, expires_delta=access_token_expires
    )
    
    user_public = UsuarioPublic.model_validate(user)
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": user_public
    }

@router.post("/register", response_model=UsuarioPublic)
async def register_user(
    user_data: UsuarioCreate,
    db: Session = Depends(get_session)
):
    return CrearUsuario(user_data, db)

# Dependencia para usar en otras rutas
async def get_current_active_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_session)
):
    user = get_current_user(db, token)
    if not user.estado:
        raise HTTPException(status_code=400, detail="Usuario inactivo")
    return user