# ruta.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

class RutaBase(SQLModel):
    Nombre: str
    Color: Optional[str] = None
    Descripcion: Optional[str] = None

class Ruta(RutaBase, table=True):
    IdRuta: Optional[int] = Field(default=None, primary_key=True)
    FechaRegistro: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )

    Puntos: List["PuntoRuta"] = Relationship(back_populates="Ruta")
    Buses: List["Bus"] = Relationship(back_populates="ruta")

class RutaCreate(RutaBase):
    pass

class RutaPublic(RutaBase):
    IdRuta: int
    FechaRegistro: datetime.datetime

class RutaUpdate(SQLModel):
    Nombre: Optional[str] = None
    Color: Optional[str] = None
    Descripcion: Optional[str] = None

Ruta.update_forward_refs()
