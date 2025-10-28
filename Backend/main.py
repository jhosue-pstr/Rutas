import sys
import os

from datetime import datetime, timedelta  
from fastapi.params import Depends
from sqlmodel import Session, func, select
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
sys.path.append(os.path.join(os.path.dirname(__file__), 'models'))


from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from config.database import create_db_and_tables, get_session
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

from static.admin_estaticas import router as admin_estadisticas_router

app = FastAPI()

# 🔥 NUEVO: Servir archivos estáticos
app.mount("/static", StaticFiles(directory="static"), name="static")

# 🔥 NUEVO: Ruta para la página admin
@app.get("/admin")
async def admin_page():
    return FileResponse("static/admin.html")

# Ruta para la página admin
@app.get("/admin")
async def admin_page():
    return FileResponse("static/admin.html")

# 🔥 INCLUIR TODOS LOS ROUTERS (SOLO 3 LÍNEAS NUEVAS)
app.include_router(admin_estadisticas_router, prefix="/api")
app.include_router(admin_debug_router, prefix="/api") 

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