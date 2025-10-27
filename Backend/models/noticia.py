from sqlmodel import SQLModel, Field, Relationship
from typing import Optional , List
from datetime import datetime

class NoticiaBase(SQLModel):
    nombre:str
    descripcion:str
    imagen:str

class Noticia(NoticiaBase, table=True):
    IdNoticia:Optional[int]=Field(default= None,primary_key=True)    
    fechaPublicacion: datetime = Field(default_factory=datetime.today)


class NoticiaCreate(NoticiaBase):
    pass


class NoticiaPublic(NoticiaBase):
    nombre:str
    descripcion:str
    imagen:str
    fechaPublicacion:datetime

class NoticiaUpdate(SQLModel):
    nombre:str
    descripcion:str
    imagen:str
