import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'models'))


from fastapi import FastAPI
from contextlib import asynccontextmanager
from config.database import create_db_and_tables
from routers.usuarios import router as users_router
from routers.auth import router as auth_router 

from routers.buses import router as buses_router
from routers.choferes import router as choferes_router
from routers.rutas import router as rutas_router
from routers.puntos_rutas import router as puntos_rutas_router 

from routers.paraderos import router as paraderos_router
from routers.lugares_cercanos import router as lugares_cercanos_router
from routers.noticias import router as noticias_router
from routers.buses_favoritos import router as buses_favoritos_router
from routers.lugares_favoritos import router as lugares_favoritos_router


from routers.simulacion import router as simulacion_router


app = FastAPI()

app.include_router(simulacion_router, prefix="/api", tags=["simulacion"])


app.include_router(auth_router, tags=["authentication"])
app.include_router(users_router, prefix="/api", tags=["usuarios"])
app.include_router(buses_router, prefix="/api", tags=["buses"])
app.include_router(choferes_router, prefix="/api", tags=["choferes"])
app.include_router(rutas_router, prefix="/api", tags=["rutas"])
app.include_router(puntos_rutas_router, prefix="/api", tags=["puntos_rutas"])

app.include_router(paraderos_router, prefix="/api", tags=["paraderos"])
app.include_router(lugares_cercanos_router, prefix="/api", tags=["lugares_cercanos"])
app.include_router(noticias_router, prefix="/api", tags=["noticias"])
app.include_router(buses_favoritos_router, prefix="/api", tags=["buses_favoritos"])
app.include_router(lugares_favoritos_router, prefix="/api", tags=["lugares_favoritos"])


@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/")
def read_root():
    return {"message": "API funcionando"} 