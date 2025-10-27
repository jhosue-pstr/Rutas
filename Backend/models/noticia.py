from sqlmodel import SQLModel, Field
from typing import Optional
import datetime
from sqlalchemy import Column, DateTime, Text

class NoticiaBase(SQLModel):
    titulo: str
    descripcion: str
    imagen_url: Optional[str] = None

class Noticia(NoticiaBase, table=True):
    IdNoticia: Optional[int] = Field(default=None, primary_key=True)
    FechaPublicacion: datetime.datetime = Field(
        default_factory=datetime.datetime.utcnow,
        sa_column=Column(DateTime(timezone=True))
    )
    # Para descripciones largas
    descripcion: str = Field(sa_column=Column(Text))

class NoticiaCreate(NoticiaBase):
    pass

class NoticiaPublic(NoticiaBase):
    IdNoticia: int
    FechaPublicacion: datetime.datetime

class NoticiaUpdate(SQLModel):
    titulo: Optional[str] = None
    descripcion: Optional[str] = None
    imagen_url: Optional[str] = None