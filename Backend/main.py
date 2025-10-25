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



app = FastAPI()

app.include_router(auth_router, tags=["authentication"])
app.include_router(users_router, prefix="/api", tags=["usuarios"])
app.include_router(buses_router, prefix="/api", tags=["buses"])
app.include_router(choferes_router, prefix="/api", tags=["choferes"])
app.include_router(rutas_router, prefix="/api", tags=["rutas"])
app.include_router(puntos_rutas_router, prefix="/api", tags=["puntos_rutas"])





@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/")
def read_root():
    return {"message": "API funcionando"} 