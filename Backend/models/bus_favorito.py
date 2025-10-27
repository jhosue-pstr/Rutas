from sqlmodel import SQLModel, Field, Relationship
from typing import Optional , List
from models.bus import Bus
from models.usuario import Usuario

class BusFavoritoBase(SQLModel):
    IdBus:int
    IdUsuario:int

class BusFavorito(BusFavoritoBase,table=True):
    IdBusFavorito:Optional[int]=Field(default= None,primary_key=True)    

    IdBus :int = Field(foreign_key="bus.IdBus")
    bus: Optional[Bus] = Relationship(back_populates="busfavorito")

    
    IdUsuario:int = Field(foreign_key="usuario.IdUsuario")
    usuario: Optional["Usuario"]= Relationship(back_populates="busfavorito")

class BusFavoritoCreate(BusFavoritoBase):
    pass

class BusFavoritoPublic(BusFavoritoBase):
    IdBus:Optional[int]=None
    IdUsuario:Optional[int]=None


class BusFavoritoUpdate(BusFavoritoBase):
       IdBus: Optional[int] = None    



BusFavoritoPublic.model_rebuild()    