from sqlmodel import SQLModel, Field, Relationship
from typing import Optional

class PuntoRutaBase(SQLModel):
    latitud: float
    longitud: float
    orden: int

class PuntoRuta(PuntoRutaBase, table=True):
    IdPunto: Optional[int] = Field(default=None, primary_key=True)
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")
    
    ruta: Optional["Ruta"] = Relationship(back_populates="puntos")

class PuntoRutaCreate(PuntoRutaBase):
    RutaId: int

class PuntoRutaPublic(PuntoRutaBase):
    IdPunto: int
    RutaId: int

class PuntoRutaUpdate(SQLModel):
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    orden: Optional[int] = None
    RutaId: Optional[int] = None