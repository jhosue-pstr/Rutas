from sqlmodel import SQLModel, Field, Relationship
from typing import Optional , List
from datetime import datetime
from fastapi import UploadFile

class NoticiaBase(SQLModel):
    nombre: str
    descripcion: str
    imagen: str

class Noticia(NoticiaBase, table=True):
    IdNoticia: Optional[int] = Field(default= None, primary_key=True)    
    fechaPublicacion: datetime = Field(default_factory=datetime.today)

class NoticiaCreate(SQLModel):
    nombre: str
    descripcion: str
    imagen: UploadFile

class NoticiaPublic(NoticiaBase):
    IdNoticia: int
    fechaPublicacion: datetime

class NoticiaUpdate(SQLModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    imagen: Optional[UploadFile] = None