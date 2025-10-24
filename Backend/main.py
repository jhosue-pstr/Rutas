import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'models'))


from fastapi import FastAPI
from contextlib import asynccontextmanager
from config.database import create_db_and_tables
from routers.usuarios import router as users_router

from routers.auth import router as auth_router 

app = FastAPI()

app.include_router(auth_router, tags=["authentication"])
app.include_router(users_router, prefix="/api", tags=["usuarios"])


os.makedirs("uploads", exist_ok=True)



@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/")
def read_root():
    return {"message": "API funcionando"} 