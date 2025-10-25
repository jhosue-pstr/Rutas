# ruta.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

class RutaBase(SQLModel):
    nombre: str
    color: Optional[str] = None
    descripcion: Optional[str] = None

class Ruta(RutaBase, table=True):
    id_ruta: Optional[int] = Field(default=None, primary_key=True)
    fecha_registro: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )

    puntos: List["PuntoRuta"] = Relationship(back_populates="ruta")
    buses: List["Bus"] = Relationship(back_populates="ruta")

class RutaCreate(RutaBase):
    pass

class RutaPublic(RutaBase):
    id_ruta: int
    fecha_registro: datetime.datetime

class RutaUpdate(SQLModel):
    nombre: Optional[str] = None
    color: Optional[str] = None
    descripcion: Optional[str] = None

Ruta.update_forward_refs()
