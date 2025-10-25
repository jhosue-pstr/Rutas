from datetime import datetime, timedelta, timezone
from typing import Optional
import jwt
from fastapi import HTTPException, status
from passlib.context import CryptContext
from sqlmodel import Session, select
import os
from models.usuario import Usuario

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "43200"))
if not SECRET_KEY:
    raise ValueError("SECRET_KEY no está configurada en las variables de entorno")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        correo: str = payload.get("sub")
        if correo is None:
            return None
        return correo
    except jwt.InvalidTokenError:
        return None

def get_user_by_email(db: Session, correo: str) -> Optional[Usuario]:
    statement = select(Usuario).where(Usuario.Correo == correo)
    return db.exec(statement).first()

def authenticate_user(db: Session, correo: str, contrasena: str):
    user = get_user_by_email(db, correo)
    if not user:
        return False
    if not verify_password(contrasena, user.Contrasena):
        return False
    return user

def get_current_user(db: Session, token: str):
    correo = verify_token(token)
    if correo is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado"
        )
    
    user = get_user_by_email(db, correo)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado"
        )
    return user