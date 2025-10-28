from sqlmodel import Field, SQLModel, Relationship
from typing import Optional, List
import datetime
from pydantic import BaseModel


class UsuarioBase(SQLModel):
    Nombre: str
    Apellido: str
    Correo: str = Field(unique=True, index=True)  

class Usuario(UsuarioBase, table=True):
    IdUsuario: Optional[int] = Field(default=None, primary_key=True)
    Contrasena: str
    FechaRegistro: datetime.date = Field(default_factory=datetime.datetime.utcnow)
    estado: bool = True

    busfavorito:Optional["BusFavorito"]= Relationship(back_populates="usuario")

class UsuarioCreate(UsuarioBase):
    Contrasena: str

class UsuarioPublic(UsuarioBase):
    IdUsuario: int
    FechaRegistro: datetime.date
    estado: bool

class UsuarioUpdate(SQLModel):
    Nombre: Optional[str] = None
    Apellido: Optional[str] = None
    Correo: Optional[str] = None
    Contrasena: Optional[str] = None
    estado: Optional[bool] = None
