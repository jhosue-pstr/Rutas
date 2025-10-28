from sqlmodel import SQLModel, Field
from typing import Optional

class LugarFavoritoBase(SQLModel):
    Nombre: str
    Latitud: float
    Longitud: float
    Descripcion: Optional[str] = None
    Color: Optional[str] = "#2196F3"
    IdUsuario: int  

class LugarFavorito(LugarFavoritoBase, table=True):
    Id: Optional[int] = Field(default=None, primary_key=True)

class LugarFavoritoCreate(LugarFavoritoBase):
    pass

class LugarFavoritoUpdate(SQLModel):
    Nombre: Optional[str] = None
    Latitud: Optional[float] = None
    Longitud: Optional[float] = None
    Descripcion: Optional[str] = None
    Color: Optional[str] = None
    IdUsuario: Optional[int] = None

class LugarFavoritoPublic(LugarFavoritoBase):
    Id: int