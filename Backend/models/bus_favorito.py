from sqlmodel import SQLModel, Field, Relationship
from typing import Optional
import datetime
from sqlalchemy import Column, DateTime

class BusFavoritoBase(SQLModel):
    UsuarioId: int = Field(foreign_key="usuario.IdUsuario")
    BusId: int = Field(foreign_key="bus.IdBus")

class BusFavorito(BusFavoritoBase, table=True):
    IdBusFavorito: Optional[int] = Field(default=None, primary_key=True)
    FechaAgregado: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )

    # relaciones
    usuario: Optional["Usuario"] = Relationship(back_populates="buses_favoritos")
    bus: Optional["Bus"] = Relationship(back_populates="favoritos")

class BusFavoritoCreate(BusFavoritoBase):
    pass

class BusFavoritoPublic(BusFavoritoBase):
    IdBusFavorito: int
    FechaAgregado: datetime.datetime

class BusFavoritoUpdate(SQLModel):
    pass