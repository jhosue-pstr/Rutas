from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

from models.bus import Bus

class ChoferBase(SQLModel):
    nombre: str
    apellido: Optional[str] = None
    dni: Optional[str] = None
    telefono: Optional[str] = None
    foto_url: Optional[str] = None
    qr_pago_url: Optional[str] = None
    licencia_conducir: Optional[str] = None

class Chofer(ChoferBase, table=True):
    IdChofer: Optional[int] = Field(default=None, primary_key=True)
    fecha_ingreso: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )
    estado: bool = True

    buses: List["Bus"] = Relationship(back_populates="chofer")

class ChoferCreate(SQLModel):
    nombre: str
    apellido: Optional[str] = None
    dni: Optional[str] = None
    telefono: Optional[str] = None

class ChoferPublic(ChoferBase):
    IdChofer: int
    fecha_ingreso: datetime.datetime
    estado: bool

class ChoferUpdate(SQLModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    dni: Optional[str] = None
    telefono: Optional[str] = None