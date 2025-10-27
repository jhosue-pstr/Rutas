from sqlmodel import SQLModel, Field, Relationship
from typing import Optional , List
from models.bus import Bus


class ParaderoBase(SQLModel):
    nombre:str
    latitud:float
    longitud:float


class Paradero(ParaderoBase,table=True):
    IdParadero:Optional[int]=Field(default= None,primary_key=True)    

    IdBus :int = Field(foreign_key="bus.IdBus")
    bus: Optional[Bus] = Relationship(back_populates="paradero")

    lugarcercano: Optional["LugarCercano"] = Relationship(back_populates="paradero")



class ParaderoCreate(ParaderoBase):
    pass

class ParaderoPublic(ParaderoBase):
    IdParadero:int
    IdBus:int

class ParaderoUpdate(SQLModel):
    nombre:Optional[str]=None
    latitud:Optional[float]=None
    longitud:Optional[float]=None



ParaderoPublic.model_rebuild()