from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
import datetime
from sqlalchemy import Column, DateTime

class ParaderoBase(SQLModel):
    nombre: str
    latitud: float
    longitud: float

class Paradero(ParaderoBase, table=True):
    IdParadero: Optional[int] = Field(default=None, primary_key=True)
    FechaRegistro: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )

    # relaciones
    lugares_cercanos: List["LugarCercano"] = Relationship(back_populates="paradero")
    buses: List["Bus"] = Relationship(back_populates="paradero")

class ParaderoCreate(ParaderoBase):
    pass

class ParaderoPublic(ParaderoBase):
    IdParadero: int
    FechaRegistro: datetime.datetime

class ParaderoUpdate(SQLModel):
    nombre: Optional[str] = None
    latitud: Optional[float] = None
    longitud: Optional[float] = None