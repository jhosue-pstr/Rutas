# punto_ruta.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional

class PuntoRutaBase(SQLModel):
    latitud: float
    longitud: float
    orden: int

class PuntoRuta(PuntoRutaBase, table=True):
    id_punto: Optional[int] = Field(default=None, primary_key=True)
    ruta_id: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")
    ruta: Optional["Ruta"] = Relationship(back_populates="puntos")

class PuntoRutaCreate(PuntoRutaBase):
    ruta_id: int

class PuntoRutaPublic(PuntoRutaBase):
    id_punto: int
    ruta_id: int

class PuntoRutaUpdate(SQLModel):
    latitud: Optional[float] = None
    longitud: Optional[float] = None
    orden: Optional[int] = None
    ruta_id: Optional[int] = None

PuntoRuta.update_forward_refs()
