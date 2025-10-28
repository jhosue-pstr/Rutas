# from sqlmodel import SQLModel, Field, Relationship
# from typing import Optional
# import datetime
# from sqlalchemy import Column, DateTime

# class BusBase(SQLModel):
#     placa: str
#     capacidad: Optional[int] = 40
#     modelo: Optional[str] = None
#     marca: Optional[str] = None

# class Bus(BusBase, table=True):
#     IdBus: Optional[int] = Field(default=None, primary_key=True)
#     ChoferId: Optional[int] = Field(default=None, foreign_key="chofer.IdChofer")
#     RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")

#     chofer: Optional["Chofer"] = Relationship(back_populates="buses")
#     ruta: Optional["Ruta"] = Relationship(back_populates="buses")
#     favoritos: Optional["BusFavorito"] = Relationship(back_populates="bus")
# paradero: Optional["Paradero"] = Relationship(back_populates="buses")

# class BusCreate(BusBase):
#     ChoferId: Optional[int] = None
#     RutaId: Optional[int] = None

# class BusPublic(BusBase):
#     IdBus: int
#     ChoferId: Optional[int]
#     RutaId: Optional[int]

# class BusUpdate(SQLModel):
#     placa: Optional[str] = None
#     capacidad: Optional[int] = None
#     RutaId: Optional[int] = None
#     ChoferId: Optional[int] = None
#     modelo: Optional[str] = None
#     marca: Optional[str] = None




# models/bus.py - VERSIÓN CORREGIDA
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
import datetime
from sqlalchemy import Column, DateTime

class BusBase(SQLModel):
    placa: str
    capacidad: Optional[int] = 40
    modelo: Optional[str] = None
    marca: Optional[str] = None
    nombre:Optional[str]=None
    numero:Optional[str]=None

class Bus(BusBase, table=True):
    IdBus: Optional[int] = Field(default=None, primary_key=True)
    ChoferId: Optional[int] = Field(default=None, foreign_key="chofer.IdChofer")
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")

    chofer: Optional["Chofer"] = Relationship(back_populates="buses")
    ruta: Optional["Ruta"] = Relationship(back_populates="buses")
    paradero: Optional["Paradero"] = Relationship(back_populates="bus")
    busfavorito:Optional["BusFavorito"]= Relationship(back_populates="bus")

class BusCreate(BusBase):
    ChoferId: Optional[int] = None
    RutaId: Optional[int] = None

class BusPublic(BusBase):
    IdBus: int
    ChoferId: Optional[int]
    RutaId: Optional[int]

class BusUpdate(SQLModel):
    placa: Optional[str] = None
    capacidad: Optional[int] = None
    RutaId: Optional[int] = None
    ChoferId: Optional[int] = None
    modelo: Optional[str] = None
    marca: Optional[str] = None