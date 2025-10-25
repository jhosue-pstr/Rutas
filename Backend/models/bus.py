from __future__ import annotations
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
    IdBus: Optional[int] = Field(default=None, primary_key=True)  # PascalCase
    ChoferId: Optional[int] = Field(default=None, foreign_key="chofer.IdChofer")  # PascalCase y foreign key corregida
    RutaId: Optional[int] = Field(default=None, foreign_key="ruta.IdRuta")  # PascalCase

    chofer: Optional["Chofer"] = Relationship(back_populates="buses")
    ruta: Optional["Ruta"] = Relationship(back_populates="buses")

class BusCreate(BusBase):
    ChoferId: Optional[int] = None  # PascalCase
    RutaId: Optional[int] = None   # PascalCase

class BusPublic(BusBase):
    IdBus: int                    # PascalCase
    ChoferId: Optional[int]       # PascalCase
    RutaId: Optional[int]         # PascalCase

class BusUpdate(SQLModel):
    placa: Optional[str] = None
    capacidad: Optional[int] = None
    RutaId: Optional[int] = None    # PascalCase
    ChoferId: Optional[int] = None  # PascalCase
    modelo: Optional[str] = None
    marca: Optional[str] = None
Bus.update_forward_refs()
