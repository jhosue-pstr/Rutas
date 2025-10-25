# bus.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
import datetime
from sqlalchemy import Column, DateTime

class BusBase(SQLModel):
    placa: str
    capacidad: Optional[int] = 40
    modelo: Optional[str] = None
    marca: Optional[str] = None

class Bus(BusBase, table=True):
    id_bus: Optional[int] = Field(default=None, primary_key=True)
    chofer_id: Optional[int] = Field(default=None, foreign_key="chofer.id_chofer")
    ruta_id: Optional[int] = Field(default=None, foreign_key="ruta.id_ruta")

    chofer: Optional["Chofer"] = Relationship(back_populates="buses")
    ruta: Optional["Ruta"] = Relationship(back_populates="buses")

class BusCreate(BusBase):
    chofer_id: Optional[int] = None
    ruta_id: Optional[int] = None

class BusPublic(BusBase):
    id_bus: int
    chofer_id: Optional[int]
    ruta_id: Optional[int]

class BusUpdate(SQLModel):
    placa: Optional[str] = None
    capacidad: Optional[int] = None
    ruta_id: Optional[int] = None
    chofer_id: Optional[int] = None
    modelo: Optional[str] = None
    marca: Optional[str] = None

Bus.update_forward_refs()
