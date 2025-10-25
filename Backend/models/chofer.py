# chofer.py
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

class ChoferBase(SQLModel):
    Nombre: str
    Apellido: Optional[str] = None
    DNI: Optional[str] = None
    Telefono: Optional[str] = None
    FotoURL: Optional[str] = None
    QRPagoURL: Optional[str] = None
    LicenciaConducir: Optional[str] = None

class Chofer(ChoferBase, table=True):
    IdChofer: Optional[int] = Field(default=None, primary_key=True)
    FechaIngreso: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )
    Estado: bool = True

    buses: List["Bus"] = Relationship(back_populates="chofer")

class ChoferCreate(ChoferBase):
    pass

class ChoferPublic(ChoferBase):
    IdChofer: int
    FechaIngreso: datetime.datetime
    Estado: bool

class ChoferUpdate(SQLModel):
    Nombre: Optional[str] = None
    Apellido: Optional[str] = None
    DNI: Optional[str] = None
    Telefono: Optional[str] = None
    QRPagoURL: Optional[str] = None
    FotoURL: Optional[str] = None
    LicenciaConducir: Optional[str] = None

Chofer.update_forward_refs()
