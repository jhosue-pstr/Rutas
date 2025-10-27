from sqlmodel import SQLModel, Field, Relationship
from typing import Optional

class LugarCercanoBase(SQLModel):
    nombre: str
    tipo: Optional[str] = None  # restaurante, banco, hospital, etc.
    distancia_metros: Optional[int] = None

class LugarCercano(LugarCercanoBase, table=True):
    IdLugarCercano: Optional[int] = Field(default=None, primary_key=True)
    ParaderoId: Optional[int] = Field(default=None, foreign_key="paradero.IdParadero")

    # relaciones
    paradero: Optional["Paradero"] = Relationship(back_populates="lugares_cercanos")

class LugarCercanoCreate(LugarCercanoBase):
    ParaderoId: int

class LugarCercanoPublic(LugarCercanoBase):
    IdLugarCercano: int
    ParaderoId: int

class LugarCercanoUpdate(SQLModel):
    nombre: Optional[str] = None
    tipo: Optional[str] = None
    distancia_metros: Optional[int] = None
    ParaderoId: Optional[int] = None