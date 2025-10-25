from __future__ import annotations
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

class RutaBase(SQLModel):
    nombre: str
    color: Optional[str] = None
    descripcion: Optional[str] = None

class Ruta(RutaBase, table=True):
    IdRuta: Optional[int] = Field(default=None, primary_key=True)
    FechaRegistro: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )

    # relaciones
    buses: List[Bus] = Relationship(back_populates="ruta")
    puntos: List[PuntoRuta] = Relationship(back_populates="ruta")

class RutaCreate(RutaBase):
    pass

class RutaPublic(RutaBase):
    IdRuta: int
    FechaRegistro: datetime.datetime

class RutaUpdate(SQLModel):
    nombre: Optional[str] = None
    color: Optional[str] = None
    descripcion: Optional[str] = None