from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime

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
    FechaIngreso: datetime.date = Field(default_factory=datetime.datetime.utcnow)
    Estado: bool = True

    Buses: List["Bus"] = Relationship(back_populates="Chofer")

class ChoferCreate(ChoferBase):
    pass

class ChoferPublic(ChoferBase):
    IdChofer: int
    FechaIngreso: datetime.date
    Estado: bool


class ChoferUpdate(SQLModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    dni: Optional[str] = None
    telefono: Optional[str] = None
    qr_pago: Optional[str] = None
    foto: Optional[str] = None