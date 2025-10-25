# punto_ruta.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
from sqlalchemy import Column, DateTime
import datetime
from .ruta import Ruta

class PuntoRutaBase(SQLModel):
    Latitud: float
    Longitud: float
    Orden: int

class PuntoRuta(PuntoRutaBase, table=True):
    IdPunto: Optional[int] = Field(default=None, primary_key=True)
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")
    Ruta: Optional["Ruta"] = Relationship(back_populates="Puntos")

class PuntoRutaCreate(PuntoRutaBase):
    RutaId: int

class PuntoRutaPublic(PuntoRutaBase):
    IdPunto: int
    RutaId: int

class PuntoRutaUpdate(SQLModel):
    Latitud: Optional[float] = None
    Longitud: Optional[float] = None
    Orden: Optional[int] = None
    RutaId: Optional[int] = None

PuntoRuta.update_forward_refs()
