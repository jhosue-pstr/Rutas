from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime

class PuntoRuta(SQLModel, table=True):
    IdPunto: Optional[int] = Field(default=None, primary_key=True)
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")
    Latitud: float
    Longitud: float
    Orden: int

class RutaBase(SQLModel):
    Nombre: str
    Color: Optional[str] = None
    Descripcion: Optional[str] = None

class Ruta(RutaBase, table=True):
    IdRuta: Optional[int] = Field(default=None, primary_key=True)
    FechaRegistro: datetime.date = Field(default_factory=datetime.datetime.utcnow)

    # Relaciones
    Puntos: List["PuntoRuta"] = Relationship(back_populates="Ruta")
    Buses: List["Bus"] = Relationship(back_populates="Ruta")

class RutaCreate(RutaBase):
    pass

class RutaPublic(RutaBase):
    IdRuta: int
    FechaRegistro: datetime.date

class RutaUpdate(SQLModel):
    nombre: Optional[str] = None
    color: Optional[str] = None
    descripcion: Optional[str] = None    
