import os
from typing import Annotated
from sqlmodel import create_engine
from dotenv import load_dotenv
from sqlmodel import Field, Session, SQLModel, create_engine, select
from fastapi import Depends, HTTPException, Query




load_dotenv()

db_user = os.getenv("USER_DB")
db_password = os.getenv("PASSWORD_DB")
db_host = os.getenv("HOST_DB")
db_port = os.getenv("PORT_DB")
db_name = os.getenv("NAME_DB")

url_connection = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
engine = create_engine(url_connection, echo=True)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)    

def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]