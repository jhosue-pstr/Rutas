from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
from .chofer import Chofer
from .ruta import Ruta

class BusBase(SQLModel):
    Placa: str
    Capacidad: Optional[int] = 40
    Modelo: Optional[str] = None
    Marca: Optional[str] = None

class Bus(BusBase, table=True):
    IdBus: Optional[int] = Field(default=None, primary_key=True)
    ChoferId: Optional[int] = Field(default=None, foreign_key="chofer.IdChofer")
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")

    Chofer: Optional[Chofer] = Relationship(back_populates="Buses")
    Ruta: Optional[Ruta] = Relationship(back_populates="Buses")

class BusCreate(BusBase):
    ChoferId: Optional[int] = None
    RutaId: Optional[int] = None

class BusPublic(BusBase):
    IdBus: int
    ChoferId: Optional[int]
    RutaId: Optional[int]
