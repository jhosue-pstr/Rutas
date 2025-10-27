from sqlmodel import SQLModel, Field, Relationship
from typing import Optional , List
from models.paradero import Paradero

class LugarCercanoBase(SQLModel):
    nombre:str

class LugarCercano(LugarCercanoBase,table=True):
    IdLugarCercano:Optional[int]=Field(default=None,primary_key=True)

    IdParadero:int=Field(foreign_key="paradero.IdParadero")
    paradero: Optional[Paradero] = Relationship(back_populates="lugarcercano")



class LugarCercanoCreate(LugarCercanoBase):
    pass

class LugarCercanoPublic(LugarCercanoBase):
    IdLugarCercano:int
    IdParadero:int


class LugarCercanoUpdate(SQLModel):
    nombre:Optional[str]=None
    IdParadero:Optional[int]=None


LugarCercanoPublic.model_rebuild()