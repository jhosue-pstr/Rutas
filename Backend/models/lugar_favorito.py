from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
import datetime
from sqlalchemy import Column, DateTime, Text

class LugarFavoritoBase(SQLModel):
    nombre: str
    latitud: float
    longitud: float
    descripcion: Optional[str] = None
    color: Optional[str] = "#2196F3"  # Color por defecto azul

class LugarFavorito(LugarFavoritoBase, table=True):
    IdLugarFavorito: Optional[int] = Field(default=None, primary_key=True)
    UsuarioId: int = Field(foreign_key="usuario.IdUsuario")
    FechaCreacion: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )
    # Para descripciones largas
    descripcion: Optional[str] = Field(default=None, sa_column=Column(Text))

    # relaciones
    usuario: Optional["Usuario"] = Relationship(back_populates="lugares_favoritos")

class LugarFavoritoCreate(LugarFavoritoBase):
    UsuarioId: int

class LugarFavoritoPublic(LugarFavoritoBase):
    IdLugarFavorito: int
    UsuarioId: int
    FechaCreacion: datetime.datetime

class LugarFavoritoUpdate(SQLModel):
    nombre: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    descripcion: Optional[str] = None
    color: Optional[str] = None